<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Commande;
use App\Models\Product;
use App\Models\Table;
use App\Enums\OrderStatus;
use App\Enums\StatutPaiement;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;

class CommandeController extends Controller
{
    /**
     * Liste des commandes
     * GET /api/commandes
     */
    public function index(Request $request)
    {
        $user = auth()->user();
        $query = Commande::with(['table', 'user', 'produits']);

        // Si l'utilisateur est un client, filtrer par ses commandes uniquement
        if ($user->hasRole('client')) {
            $query->where('user_id', $user->id);
        }

        // Filtre spécial pour "Mes commandes" (current) : commandes du jour non terminées
        if ($request->has('filter') && $request->filter === 'current') {
            $query->duJour()
                  ->where('statut', '!=', OrderStatus::Terminee);
        }
        // Filtre spécial pour "Historique" (history) : commandes terminées uniquement
        elseif ($request->has('filter') && $request->filter === 'history') {
            $query->where('statut', OrderStatus::Terminee);
        }
        // Comportement par défaut (pour compatibilité)
        else {
            // Filtres standards
            if ($request->has('table_id')) {
                $query->ofTable($request->table_id);
            }

            if ($request->has('statut')) {
                $query->ofStatut($request->statut);
            }

            if ($request->has('date')) {
                $query->whereDate('created_at', $request->date);
            } elseif ($request->has('all') && $request->boolean('all')) {
                // Si le paramètre 'all' est présent et vrai, récupérer toutes les commandes
                // (pas de filtre de date)
            } else {
                // Par défaut, commandes du jour (sauf pour les clients qui voient toutes leurs commandes terminées)
                if (!$user->hasRole('client')) {
                    $query->duJour();
                } else {
                    // Pour les clients, par défaut on montre les terminées (historique)
                    $query->where('statut', OrderStatus::Terminee);
                }
            }
        }

        $commandes = $query->orderBy('created_at', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $commandes->map(fn($c) => $this->formatCommande($c)),
        ]);
    }

    /**
     * Créer une commande
     * POST /api/commandes
     */
    public function store(Request $request)
    {
        // Log pour débogage
        Log::info('CommandeController::store - Données reçues', [
            'request_data' => $request->all(),
            'user_id' => auth()->id(),
        ]);

        $validator = Validator::make($request->all(), [
            'table_id' => 'required|exists:tables,id',
            'notes' => 'nullable|string',
            'produits' => 'required|array|min:1',
            'produits.*.produit_id' => 'required|exists:produits,id',
            'produits.*.quantite' => 'required|integer|min:1',
            'produits.*.notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            Log::error('CommandeController::store - Erreur de validation', [
                'errors' => $validator->errors()->toArray(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        DB::beginTransaction();
        try {
            // Vérifier s'il y a déjà une commande active sur cette table
            $existingOrder = Commande::where('table_id', $request->table_id)
                ->whereNotIn('statut', [OrderStatus::Terminee, OrderStatus::Annulee])
                ->first();

            if ($existingOrder) {
                DB::rollBack();
                return response()->json([
                    'success' => false,
                    'message' => 'Une commande est déjà en cours sur cette table.',
                    'data' => ['existing_order_id' => $existingOrder->id],
                ], 409); // Conflict
            }

            // Créer la commande
            $commande = Commande::create([
                'table_id' => $request->table_id,
                'user_id' => auth()->id(),
                'statut' => OrderStatus::Attente,
                'notes' => $request->notes,
            ]);
            
            Log::info('CommandeController::store - Commande créée', [
                'commande_id' => $commande->id,
            ]);

            // Ajouter les produits
            foreach ($request->produits as $item) {
                $produit = Product::find($item['produit_id']);
                
                if (!$produit) {
                    DB::rollBack();
                    Log::error('CommandeController::store - Produit non trouvé', [
                        'produit_id' => $item['produit_id'] ?? null,
                    ]);
                    return response()->json([
                        'success' => false,
                        'message' => "Le produit avec l'ID {$item['produit_id']} n'existe pas",
                    ], 400);
                }
                
                if (!$produit->isDisponible()) {
                    DB::rollBack();
                    Log::warning('CommandeController::store - Produit non disponible', [
                        'produit_id' => $produit->id,
                        'produit_nom' => $produit->nom,
                    ]);
                    return response()->json([
                        'success' => false,
                        'message' => "Le produit {$produit->nom} n'est pas disponible",
                    ], 400);
                }

                try {
                $commande->produits()->attach($produit->id, [
                    'quantite' => $item['quantite'],
                    'prix_unitaire' => $produit->prix,
                    'notes' => $item['notes'] ?? null,
                    'statut' => 'envoye', // Directement envoyé à la création
                ]);
                } catch (\Exception $e) {
                    DB::rollBack();
                    Log::error('CommandeController::store - Erreur lors de l\'ajout du produit', [
                        'produit_id' => $produit->id,
                        'error' => $e->getMessage(),
                        'trace' => $e->getTraceAsString(),
                    ]);
                    throw $e;
                }
            }

            // Marquer la table comme occupée
            $table = Table::find($request->table_id);
            if ($table->isLibre()) {
                $table->occuper();
            }

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Commande créée avec succès',
                'data' => $this->formatCommande($commande->fresh()->load(['table', 'user', 'produits'])),
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('CommandeController::store - Exception', [
                'message' => $e->getMessage(),
                'trace' => $e->getTraceAsString(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Erreur serveur. Veuillez réessayer plus tard.',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne du serveur',
            ], 500);
        }
    }

    /**
     * Afficher une commande
     * GET /api/commandes/{id}
     */
    public function show($id)
    {
        $commande = Commande::with(['table', 'user', 'produits', 'paiements.facture'])->find($id);

        if (!$commande) {
            return response()->json([
                'success' => false,
                'message' => 'Commande non trouvée',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $this->formatCommande($commande),
        ]);
    }

    /**
     * Récupérer la facture d'une commande
     * GET /api/commandes/{id}/facture
     */
    public function getFacture($id)
    {
        $commande = Commande::with(['table', 'user', 'produits'])->find($id);

        if (!$commande) {
            return response()->json([
                'success' => false,
                'message' => 'Commande non trouvée',
            ], 404);
        }

        // Récupérer le paiement validé de la commande
        $paiementValide = $commande->paiements()->where('statut', \App\Enums\StatutPaiement::Valide)->latest()->first();

        if (!$paiementValide || !$paiementValide->facture) {
            return response()->json([
                'success' => false,
                'message' => 'Aucune facture disponible pour cette commande.',
            ], 404);
        }

        $facture = $paiementValide->facture->load(['commande.table', 'commande.produits', 'paiement']);

        return response()->json([
            'success' => true,
            'data' => [
                'id' => (int) $facture->id,
                'numero_facture' => $facture->numero_facture,
                'commande_id' => (int) $facture->commande_id,
                'paiement_id' => (int) $facture->paiement_id,
                'montant_total' => (float) $facture->montant_total,
                'montant_taxe' => (float) $facture->montant_taxe,
                'pdf_url' => $facture->pdf_url,
                'created_at' => $facture->created_at->toIso8601String(),
                'commande' => $this->formatCommande($commande),
                'paiement' => [
                    'id' => (int) $paiementValide->id,
                    'montant' => (float) $paiementValide->montant,
                    'moyen_paiement' => $paiementValide->moyen_paiement->value,
                    'statut' => $paiementValide->statut->value,
                    'transaction_id' => $paiementValide->transaction_id,
                    'montant_recu' => $paiementValide->montant_recu ? (float) $paiementValide->montant_recu : null,
                    'monnaie_rendue' => $paiementValide->monnaie_rendue ? (float) $paiementValide->monnaie_rendue : null,
                    'created_at' => $paiementValide->created_at->toIso8601String(),
                ],
            ],
        ]);
    }

    /**
     * Mettre à jour une commande (ajouter/modifier produits)
     * PUT/PATCH /api/commandes/{id}
     */
    public function update(Request $request, $id)
    {
        $commande = Commande::find($id);

        if (!$commande) {
            return response()->json([
                'success' => false,
                'message' => 'Commande non trouvée',
            ], 404);
        }

        if (!$commande->peutEtreModifiee()) {
            return response()->json([
                'success' => false,
                'message' => 'Cette commande ne peut plus être modifiée',
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'notes' => 'nullable|string',
            'statut' => 'sometimes|in:attente,preparation,servie,terminee,annulee',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        $commande->update($validator->validated());

        // Gérer l'ajout de produits en mode "Brouillon"
        if ($request->has('produits') && is_array($request->produits)) {
             foreach ($request->produits as $item) {
                 if (isset($item['id']) && isset($item['quantite'])) {
                     $produit = Product::find($item['id']);
                     if ($produit) {
                         // On ajoute sans supprimer les existants (attach vs sync)
                         // Et on met le statut 'brouillon' pour les nouveaux
                         $commande->produits()->attach($produit->id, [
                             'quantite' => $item['quantite'],
                             'prix_unitaire' => $produit->prix,
                             'notes' => $item['notes'] ?? null,
                             'statut' => 'brouillon',
                         ]);
                     }
                 }
             }
        }

        return response()->json([
            'success' => true,
            'message' => 'Commande mise à jour avec succès',
            'data' => $this->formatCommande($commande->fresh()->load(['table', 'user', 'produits'])),
        ]);
    }

    /**
     * Ajouter un produit à une commande existante
     * POST /api/commandes/{id}/produits
     */
    public function addProduit(Request $request, $id)
    {
        $commande = Commande::find($id);

        if (!$commande) {
            return response()->json([
                'success' => false,
                'message' => 'Commande non trouvée',
            ], 404);
        }

        // Vérifier que l'utilisateur est le propriétaire de la commande (pour les clients)
        // Les admins, managers, serveurs et caissiers peuvent modifier n'importe quelle commande
        $user = auth()->user();
        if ($user->hasRole('client') && $commande->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'êtes pas autorisé à modifier cette commande',
            ], 403);
        }

        if (!$commande->peutEtreModifiee()) {
            return response()->json([
                'success' => false,
                'message' => 'Cette commande ne peut plus être modifiée',
            ], 400);
        }

        $validator = Validator::make($request->all(), [
            'produit_id' => 'required|exists:produits,id',
            'quantite' => 'required|integer|min:1',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        $produit = Product::find($request->produit_id);

        if (!$produit->isDisponible()) {
            return response()->json([
                'success' => false,
                'message' => "Le produit {$produit->nom} n'est pas disponible",
            ], 400);
        }

        $commande->ajouterProduit($produit, $request->quantite, $request->notes);

        return response()->json([
            'success' => true,
            'message' => 'Produit ajouté avec succès',
            'data' => $this->formatCommande($commande->fresh()->load(['table', 'user', 'produits'])),
        ]);
    }

    /**
     * Retirer un produit d'une commande
     * DELETE /api/commandes/{id}/produits/{produitId}
     */
    public function removeProduit($id, $produitId)
    {
        $commande = Commande::find($id);

        if (!$commande) {
            return response()->json([
                'success' => false,
                'message' => 'Commande non trouvée',
            ], 404);
        }

        if (!$commande->peutEtreModifiee()) {
            return response()->json([
                'success' => false,
                'message' => 'Cette commande ne peut plus être modifiée',
            ], 400);
        }

        $commande->retirerProduit($produitId);

        return response()->json([
            'success' => true,
            'message' => 'Produit retiré avec succès',
            'data' => $this->formatCommande($commande->fresh()->load(['table', 'user', 'produits'])),
        ]);
    }

    /**
     * Lancer les produits en brouillon (valider la commande)
     * POST /api/commandes/{id}/lancer
     */
    public function lancer($id)
    {
        $commande = Commande::find($id);

        if (!$commande) {
            return response()->json(['success' => false, 'message' => 'Commande non trouvée'], 404);
        }

        // Mettre à jour tous les produits 'brouillon' en 'envoye'
        DB::table('commande_produit')
            ->where('commande_id', $commande->id)
            ->where('statut', 'brouillon')
            ->update(['statut' => 'envoye']);

        // Mettre à jour le statut global de la commande si nécessaire
        // Si la commande était en attente, elle passe en préparation
        if ($commande->statut === OrderStatus::Attente) {
             $commande->update(['statut' => OrderStatus::Preparation]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Commande lancée en cuisine !',
            'data' => $this->formatCommande($commande->fresh()->load(['table', 'user', 'produits'])),
        ]);
    }

    /**
     * Changer le statut d'une commande
     * PATCH /api/commandes/{id}/statut
     */
    public function updateStatut(Request $request, $id)
    {
        $commande = Commande::find($id);

        if (!$commande) {
            return response()->json([
                'success' => false,
                'message' => 'Commande non trouvée',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'statut' => 'required|in:attente,preparation,servie,terminee,annulee',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        // Vérifier que l'utilisateur a les permissions pour changer le statut
        // Les clients ne peuvent pas changer le statut manuellement (sauf lancer)
        $user = auth()->user();
        if ($user->hasRole('client')) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'êtes pas autorisé à modifier le statut de cette commande',
            ], 403);
        }

        $commande->update(['statut' => OrderStatus::from($validator->validated()['statut'])]);

        return response()->json([
            'success' => true,
            'message' => 'Statut mis à jour avec succès',
            'data' => $this->formatCommande($commande->fresh()->load(['table', 'user', 'produits'])),
        ]);
    }

    /**
     * Formater une commande pour la réponse
     */
    private function formatCommande(Commande $commande): array
    {
        // Convertir l'enum en string pour l'API
        $statutValue = $commande->statut instanceof OrderStatus 
            ? $commande->statut->value 
            : $commande->statut;
        
        return [
            'id' => $commande->id,
            'table' => $commande->table ? [
                'id' => $commande->table->id,
                'numero' => $commande->table->numero,
                'type' => $commande->table->type instanceof \App\Enums\TableType 
                    ? $commande->table->type->value 
                    : $commande->table->type,
                'capacite' => $commande->table->capacite,
                'statut' => $commande->table->statut instanceof \App\Enums\TableStatus
                    ? $commande->table->statut->value
                    : $commande->table->statut,
                'prix' => $commande->table->prix,
                'prix_par_heure' => $commande->table->prix_par_heure,
                'actif' => $commande->table->actif,
            ] : null,
            'user' => $commande->user ? [
                'id' => $commande->user->id,
                'name' => $commande->user->name,
            ] : null,
            'statut' => $statutValue,
            'statut_display' => $commande->statut_display,
            'montant_total' => (float) $commande->montant_total,
            'notes' => $commande->notes,
            'produits' => $commande->produits->map(function($produit) {
                return [
                    'id' => (int) $produit->id,
                    'nom' => $produit->nom,
                    'prix_unitaire' => (float) $produit->pivot->prix_unitaire,
                    'quantite' => (int) $produit->pivot->quantite,
                    'notes' => $produit->pivot->notes,
                    'statut' => $produit->pivot->statut ?? 'envoye', // Défaut à envoye pour compatibilité
                    'sous_total' => (float) ($produit->pivot->prix_unitaire * $produit->pivot->quantite),
                ];
            }),
            'created_at' => $commande->created_at ? $commande->created_at->toIso8601String() : null,
            'updated_at' => $commande->updated_at ? $commande->updated_at->toIso8601String() : null,
        ];
    }
}
