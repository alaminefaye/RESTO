<?php

namespace App\Http\Controllers\Web;

use App\Http\Controllers\Controller;
use App\Models\Commande;
use App\Models\Paiement;
use App\Models\Facture;
use App\Enums\MoyenPaiement;
use App\Enums\StatutPaiement;
use App\Enums\OrderStatus;
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
     * Interface de caisse - Liste des commandes à payer
     */
    public function caisse()
    {
        $commandesEnAttente = Commande::with(['table', 'user', 'produits'])
            ->whereIn('statut', [OrderStatus::Servie, OrderStatus::Preparation, OrderStatus::Attente])
            ->orderBy('created_at', 'desc')
            ->get();

        return view('caisse.index', compact('commandesEnAttente'));
    }

    /**
     * Afficher le formulaire de paiement pour une commande
     */
    public function payer(Commande $commande)
    {
        if ($commande->statut === OrderStatus::Terminee) {
            return redirect()->route('caisse.index')
                            ->with('error', 'Cette commande a déjà été payée.');
        }

        $commande->load(['table', 'produits']);
        $moyensPaiement = MoyenPaiement::cases();

        return view('caisse.payer', compact('commande', 'moyensPaiement'));
    }

    /**
     * Traiter un paiement
     */
    public function traiterPaiement(Request $request, Commande $commande)
    {
        $validated = $request->validate([
            'moyen_paiement' => ['required', Rule::enum(MoyenPaiement::class)],
            'montant_recu' => 'nullable|numeric|min:0',
            'reference_transaction' => 'nullable|string|max:255',
            'notes' => 'nullable|string',
        ]);

        if ($commande->statut === OrderStatus::Terminee) {
            return redirect()->route('caisse.index')
                            ->with('error', 'Cette commande a déjà été payée.');
        }

        return DB::transaction(function () use ($validated, $request, $commande) {
            $montantAPayer = $commande->montant_total;
            $moyenPaiement = MoyenPaiement::from($validated['moyen_paiement']);
            $montantRecu = $validated['montant_recu'] ?? $montantAPayer;
            $monnaieRendue = 0;
            $statutPaiement = StatutPaiement::EnAttente;

            // Validation selon le moyen de paiement
            if ($moyenPaiement === MoyenPaiement::Especes) {
                if ($montantRecu < $montantAPayer) {
                    return back()->with('error', 'Le montant reçu est insuffisant.')
                                 ->withInput();
                }
                $monnaieRendue = $montantRecu - $montantAPayer;
                $statutPaiement = StatutPaiement::Valide;
            } else {
                // Pour mobile money et carte bancaire
                if (empty($validated['reference_transaction'])) {
                    return back()->with('error', 'La référence de transaction est requise pour ce moyen de paiement.')
                                 ->withInput();
                }
                $statutPaiement = StatutPaiement::Valide; // On suppose que c'est validé immédiatement
            }

            // Créer le paiement
            $paiement = Paiement::create([
                'commande_id' => $commande->id,
                'user_id' => auth()->id(),
                'moyen_paiement' => $moyenPaiement,
                'montant' => $montantAPayer,
                'montant_recu' => $montantRecu,
                'monnaie_rendue' => $monnaieRendue,
                'statut' => $statutPaiement,
                'transaction_id' => $validated['reference_transaction'] ?? null,
                'notes' => $validated['notes'] ?? null,
            ]);

            // Mettre à jour la commande
            $commande->statut = OrderStatus::Terminee;
            $commande->save();

            // Libérer la table
            $commande->table->liberer();

            // Générer la facture
            $facture = $this->factureService->genererFacture($commande, $paiement);

            return redirect()->route('caisse.facture', $facture)
                            ->with('success', 'Paiement enregistré avec succès !');
        });
    }

    /**
     * Afficher une facture
     */
    public function afficherFacture(Facture $facture)
    {
        $facture->load(['commande.table', 'commande.produits', 'paiement']);
        return view('caisse.facture', compact('facture'));
    }

    /**
     * Télécharger le PDF d'une facture
     */
    public function telechargerFacture(Facture $facture)
    {
        if (!$facture->chemin_pdf) {
            return back()->with('error', 'Aucun fichier PDF disponible pour cette facture.');
        }

        return response()->download(
            storage_path('app/' . $facture->chemin_pdf),
            'facture-' . $facture->numero_facture . '.pdf'
        );
    }

    /**
     * Historique des paiements
     */
    public function historique()
    {
        $paiements = Paiement::with(['commande.table', 'user', 'facture'])
                            ->orderBy('created_at', 'desc')
                            ->paginate(20);

        return view('caisse.historique', compact('paiements'));
    }
}
