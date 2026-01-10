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
        return response()->json([
            'success' => true,
            'data' => $paiements,
        ]);
    }

    /**
     * Affiche un paiement spécifique
     */
    public function show(Paiement $paiement)
    {
        return response()->json([
            'success' => true,
            'data' => $paiement->load(['commande.table', 'commande.produits', 'user', 'facture']),
        ]);
    }

    /**
     * Initie un nouveau paiement
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'commande_id' => 'required|exists:commandes,id',
            'moyen_paiement' => ['required', Rule::enum(MoyenPaiement::class)],
            'transaction_id' => 'nullable|string', // Pour mobile money
            'notes' => 'nullable|string',
        ]);

        return DB::transaction(function () use ($validated, $request) {
            $commande = Commande::with('table')->findOrFail($validated['commande_id']);
            $user = $request->user();
            $moyenPaiement = MoyenPaiement::from($validated['moyen_paiement']);

            // Vérifier si la commande n'est pas déjà payée
            if ($commande->paiements()->where('statut', StatutPaiement::Valide)->exists()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cette commande a déjà été payée.',
                ], 409);
            }

            // Les clients ne peuvent initier que des paiements Wave ou Orange Money
            if ($user->hasRole('client') && !in_array($moyenPaiement, [MoyenPaiement::Wave, MoyenPaiement::OrangeMoney])) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vous ne pouvez initier que des paiements Wave ou Orange Money. Pour le paiement en espèces, veuillez contacter le serveur.',
                ], 403);
            }

            // Vérifier que le client est propriétaire de la commande
            if ($user->hasRole('client') && $commande->user_id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Vous n\'êtes pas autorisé à payer cette commande.',
                ], 403);
            }

            // Créer le paiement
            $paiement = Paiement::create([
                'commande_id' => $commande->id,
                'user_id' => $user->id,
                'montant' => $commande->montant_total,
                'moyen_paiement' => $moyenPaiement,
                'statut' => StatutPaiement::EnAttente,
                'transaction_id' => $validated['transaction_id'] ?? null,
                'notes' => $validated['notes'] ?? null,
            ]);

            // Pour Wave et Orange Money : le paiement reste en attente, le client doit confirmer
            // Pour Espèces : le gérant doit utiliser payerEspeces
            // Pour Carte Bancaire : peut être validé directement selon le cas

            // Mettre la table en statut "en paiement" si ce n'est pas déjà le cas
            if ($commande->table->statut !== \App\Enums\TableStatus::EnPaiement) {
                $commande->table->enPaiement();
            }

            return response()->json([
                'success' => true,
                'message' => 'Paiement initié avec succès',
                'data' => $paiement->load(['commande', 'facture']),
            ], 201);
        });
    }

    /**
     * Valide un paiement (pour mobile money - Wave, Orange Money)
     * Le client confirme d'abord, puis le gérant valide
     */
    public function valider(Request $request, Paiement $paiement)
    {
        if ($paiement->statut === StatutPaiement::Valide) {
            return response()->json([
                'success' => false,
                'message' => 'Ce paiement est déjà validé.',
            ], 409);
        }

        // Vérifier que c'est un paiement mobile money (Wave ou Orange Money)
        if (!in_array($paiement->moyen_paiement, [MoyenPaiement::Wave, MoyenPaiement::OrangeMoney])) {
            return response()->json([
                'success' => false,
                'message' => 'Cette méthode de validation ne s\'applique qu\'aux paiements mobile money.',
            ], 400);
        }

        return DB::transaction(function () use ($paiement, $request) {
            // Valider le paiement
            $paiement->valider();

            // Générer la facture
            $facture = $this->factureService->genererFacture($paiement->commande, $paiement);

            // Mettre à jour le statut de la commande
            $paiement->commande->update(['statut' => OrderStatus::Terminee]);

            // Libérer la table
            $paiement->commande->table->liberer();

            return response()->json([
                'success' => true,
                'message' => 'Paiement validé avec succès',
                'data' => [
                    'paiement' => $paiement->fresh()->load('facture'),
                    'facture' => $facture,
                ],
            ]);
        });
    }

    /**
     * Client confirme un paiement mobile money (Wave, Orange Money)
     * POST /api/paiements/{id}/confirmer
     */
    public function confirmer(Request $request, Paiement $paiement)
    {
        if ($paiement->statut !== StatutPaiement::EnAttente) {
            return response()->json([
                'success' => false,
                'message' => 'Ce paiement ne peut plus être confirmé.',
            ], 400);
        }

        // Vérifier que c'est un paiement mobile money
        if (!in_array($paiement->moyen_paiement, [MoyenPaiement::Wave, MoyenPaiement::OrangeMoney])) {
            return response()->json([
                'success' => false,
                'message' => 'Cette méthode de confirmation ne s\'applique qu\'aux paiements mobile money.',
            ], 400);
        }

        // Vérifier que le client est le propriétaire de la commande
        $user = auth()->user();
        if ($user->hasRole('client') && $paiement->commande->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'êtes pas autorisé à confirmer ce paiement.',
            ], 403);
        }

        $validated = $request->validate([
            'transaction_id' => 'required|string|max:255',
        ]);

        // Mettre à jour le transaction_id
        $paiement->update(['transaction_id' => $validated['transaction_id']]);

        // Le paiement reste en attente, le gérant devra le valider
        return response()->json([
            'success' => true,
            'message' => 'Paiement confirmé. En attente de validation par le gérant.',
            'data' => $paiement->fresh()->load(['commande', 'facture']),
        ]);
    }

    /**
     * Marque un paiement comme échoué
     */
    public function echouer(Paiement $paiement)
    {
        if ($paiement->statut === StatutPaiement::Valide) {
            return response()->json([
                'success' => false,
                'message' => 'Impossible de marquer comme échoué un paiement déjà validé.',
            ], 409);
        }

        return DB::transaction(function () use ($paiement) {
            $paiement->echouer();

            // Remettre la table en statut occupé
            $paiement->commande->table->occuper();

            return response()->json([
                'success' => true,
                'message' => 'Paiement marqué comme échoué',
                'data' => $paiement->fresh(),
            ]);
        });
    }

    /**
     * Annule un paiement
     */
    public function annuler(Paiement $paiement)
    {
        if ($paiement->statut === StatutPaiement::Valide) {
            return response()->json([
                'success' => false,
                'message' => 'Impossible d\'annuler un paiement validé.',
            ], 409);
        }

        return DB::transaction(function () use ($paiement) {
            $paiement->update(['statut' => StatutPaiement::Annule]);

            // Remettre la table en statut occupé
            $paiement->commande->table->occuper();

            return response()->json([
                'success' => true,
                'message' => 'Paiement annulé',
                'data' => $paiement->fresh(),
            ]);
        });
    }

    /**
     * Télécharge la facture d'un paiement
     */
    public function telechargerFacture(Paiement $paiement)
    {
        if (!$paiement->facture) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune facture disponible pour ce paiement.',
            ], 404);
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
                return response()->json([
                    'success' => false,
                    'message' => 'Cette commande a déjà été payée.',
                ], 409);
            }

            // Vérifier le montant reçu
            if ($validated['montant_recu'] < $commande->montant_total) {
                return response()->json([
                    'success' => false,
                    'message' => 'Le montant reçu est insuffisant.',
                    'data' => [
                        'montant_requis' => $commande->montant_total,
                        'montant_recu' => $validated['montant_recu'],
                        'manquant' => $commande->montant_total - $validated['montant_recu'],
                    ],
                ], 422);
            }

            // Créer le paiement
            $paiement = Paiement::create([
                'commande_id' => $commande->id,
                'user_id' => $request->user()->id,
                'montant' => $commande->montant_total,
                'moyen_paiement' => MoyenPaiement::Especes,
                'statut' => StatutPaiement::Valide, // Validé directement pour espèces
                'montant_recu' => $validated['montant_recu'],
                'notes' => $validated['notes'] ?? null,
            ]);

            // Calculer la monnaie
            $paiement->calculerMonnaie();

            // Générer la facture
            $facture = $this->factureService->genererFacture($commande, $paiement);

            // Terminer la commande
            $commande->update(['statut' => OrderStatus::Terminee]);

            // Libérer la table
            $commande->table->liberer();

            return response()->json([
                'success' => true,
                'message' => 'Paiement espèces effectué avec succès',
                'data' => [
                    'paiement' => $paiement->fresh()->load('facture'),
                    'facture' => $facture,
                    'monnaie_rendue' => $paiement->monnaie_rendue,
                ],
            ], 201);
        });
    }
}
