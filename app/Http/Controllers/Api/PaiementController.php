<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Paiement;
use App\Models\Commande;
use App\Models\Facture;
use App\Enums\StatutPaiement;
use App\Enums\MoyenPaiement;
use App\Enums\OrderStatus;
use App\Enums\TableStatus;
use App\Services\FactureService;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\DB;

class PaiementController extends Controller
{
    protected $factureService;

    public function __construct(FactureService $factureService)
    {
        $this->factureService = $factureService;
    }

    /**
     * Liste tous les paiements
     */
    public function index()
    {
        $paiements = Paiement::with(['commande.table', 'user', 'facture'])->get();
        return response()->json($paiements);
    }

    /**
     * Affiche un paiement spécifique
     */
    public function show(Paiement $paiement)
    {
        return response()->json($paiement->load(['commande.table', 'commande.products', 'user', 'facture']));
    }

    /**
     * Initie un nouveau paiement
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'commande_id' => 'required|exists:commandes,id',
            'moyen_paiement' => ['required', Rule::enum(MoyenPaiement::class)],
            'montant_recu' => 'nullable|numeric|min:0', // Pour espèces
            'transaction_id' => 'nullable|string', // Pour mobile money
            'notes' => 'nullable|string',
        ]);

        return DB::transaction(function () use ($validated, $request) {
            $commande = Commande::with('table')->findOrFail($validated['commande_id']);

            // Vérifier si la commande n'est pas déjà payée
            if ($commande->paiements()->where('statut', StatutPaiement::Valide)->exists()) {
                return response()->json(['message' => 'Cette commande a déjà été payée.'], 409);
            }

            // Créer le paiement
            $paiement = Paiement::create([
                'commande_id' => $commande->id,
                'user_id' => $request->user()->id,
                'montant' => $commande->total_amount,
                'moyen_paiement' => $validated['moyen_paiement'],
                'statut' => StatutPaiement::EnAttente,
                'montant_recu' => $validated['montant_recu'] ?? null,
                'transaction_id' => $validated['transaction_id'] ?? null,
                'notes' => $validated['notes'] ?? null,
            ]);

            // Si paiement en espèces, calculer la monnaie
            if ($paiement->moyen_paiement === MoyenPaiement::Especes) {
                if (!$validated['montant_recu'] || $validated['montant_recu'] < $commande->total_amount) {
                    DB::rollBack();
                    return response()->json([
                        'message' => 'Le montant reçu doit être supérieur ou égal au montant de la commande.',
                    ], 422);
                }
                $paiement->calculerMonnaie();
                
                // Valider automatiquement le paiement espèces
                $paiement->valider();
            }

            // Mettre la table en statut "en paiement"
            $commande->table->enPaiement();

            return response()->json([
                'message' => 'Paiement initié avec succès',
                'paiement' => $paiement->load(['commande', 'facture']),
                'monnaie_rendue' => $paiement->monnaie_rendue,
            ], 201);
        });
    }

    /**
     * Valide un paiement (pour mobile money principalement)
     */
    public function valider(Request $request, Paiement $paiement)
    {
        if ($paiement->statut === StatutPaiement::Valide) {
            return response()->json(['message' => 'Ce paiement est déjà validé.'], 409);
        }

        return DB::transaction(function () use ($paiement, $request) {
            // Valider le paiement
            $paiement->valider();

            // Générer la facture
            $facture = $this->factureService->genererFacture($paiement->commande, $paiement);

            // Mettre à jour le statut de la commande
            $paiement->commande->update(['status' => OrderStatus::Completed]);

            // Libérer la table
            $paiement->commande->table->liberer();

            return response()->json([
                'message' => 'Paiement validé avec succès',
                'paiement' => $paiement->fresh()->load('facture'),
                'facture' => $facture,
            ]);
        });
    }

    /**
     * Marque un paiement comme échoué
     */
    public function echouer(Paiement $paiement)
    {
        if ($paiement->statut === StatutPaiement::Valide) {
            return response()->json(['message' => 'Impossible de marquer comme échoué un paiement déjà validé.'], 409);
        }

        return DB::transaction(function () use ($paiement) {
            $paiement->echouer();

            // Remettre la table en statut occupé
            $paiement->commande->table->occuper();

            return response()->json([
                'message' => 'Paiement marqué comme échoué',
                'paiement' => $paiement,
            ]);
        });
    }

    /**
     * Annule un paiement
     */
    public function annuler(Paiement $paiement)
    {
        if ($paiement->statut === StatutPaiement::Valide) {
            return response()->json(['message' => 'Impossible d\'annuler un paiement validé.'], 409);
        }

        return DB::transaction(function () use ($paiement) {
            $paiement->update(['statut' => StatutPaiement::Annule]);

            // Remettre la table en statut occupé
            $paiement->commande->table->occuper();

            return response()->json([
                'message' => 'Paiement annulé',
                'paiement' => $paiement,
            ]);
        });
    }

    /**
     * Télécharge la facture d'un paiement
     */
    public function telechargerFacture(Paiement $paiement)
    {
        if (!$paiement->facture) {
            return response()->json(['message' => 'Aucune facture disponible pour ce paiement.'], 404);
        }

        return $this->factureService->telechargerFacture($paiement->facture);
    }

    /**
     * Workflow complet de paiement espèces (création + validation automatique)
     */
    public function payerEspeces(Request $request)
    {
        $validated = $request->validate([
            'commande_id' => 'required|exists:commandes,id',
            'montant_recu' => 'required|numeric|min:0',
            'notes' => 'nullable|string',
        ]);

        return DB::transaction(function () use ($validated, $request) {
            $commande = Commande::with(['table', 'products'])->findOrFail($validated['commande_id']);

            // Vérifier si la commande n'est pas déjà payée
            if ($commande->paiements()->where('statut', StatutPaiement::Valide)->exists()) {
                return response()->json(['message' => 'Cette commande a déjà été payée.'], 409);
            }

            // Vérifier le montant reçu
            if ($validated['montant_recu'] < $commande->total_amount) {
                return response()->json([
                    'message' => 'Le montant reçu est insuffisant.',
                    'montant_requis' => $commande->total_amount,
                    'montant_recu' => $validated['montant_recu'],
                    'manquant' => $commande->total_amount - $validated['montant_recu'],
                ], 422);
            }

            // Créer le paiement
            $paiement = Paiement::create([
                'commande_id' => $commande->id,
                'user_id' => $request->user()->id,
                'montant' => $commande->total_amount,
                'moyen_paiement' => MoyenPaiement::Especes,
                'statut' => StatutPaiement::Valide, // Validé directement
                'montant_recu' => $validated['montant_recu'],
                'notes' => $validated['notes'] ?? null,
            ]);

            // Calculer la monnaie
            $paiement->calculerMonnaie();

            // Générer la facture
            $facture = $this->factureService->genererFacture($commande, $paiement);

            // Terminer la commande
            $commande->update(['status' => OrderStatus::Completed]);

            // Libérer la table
            $commande->table->liberer();

            return response()->json([
                'message' => 'Paiement espèces effectué avec succès',
                'paiement' => $paiement->fresh()->load('facture'),
                'facture' => $facture,
                'monnaie_rendue' => $paiement->monnaie_rendue,
            ], 201);
        });
    }
}
