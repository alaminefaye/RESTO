<?php

namespace App\Http\Controllers;

use App\Models\Table;
use App\Models\Commande;
use App\Models\Paiement;
use App\Models\Product;
use App\Enums\TableStatus;
use Illuminate\Http\Request;

class DashboardController extends Controller
{
    public function index()
    {
        // Statistiques tables
        $tablesTotal = Table::count();
        $tablesLibres = Table::where('statut', TableStatus::Libre)->count();
        $tablesOccupees = Table::where('statut', TableStatus::Occupee)->count();
        
        // Statistiques commandes du jour
        $commandesJour = Commande::whereDate('created_at', today())->count();
        $commandesEnCours = Commande::whereIn('statut', ['attente', 'preparation'])->count();
        
        // Chiffre d'affaires
        $caJour = Paiement::whereDate('created_at', today())
                         ->where('statut', 'valide')
                         ->sum('montant');
        
        $caSemaine = Paiement::whereBetween('created_at', [now()->startOfWeek(), now()->endOfWeek()])
                            ->where('statut', 'valide')
                            ->sum('montant');
        
        // Produits populaires du jour
        $produitsPopulaires = Commande::whereDate('commandes.created_at', today())
            ->join('commande_produit', 'commandes.id', '=', 'commande_produit.commande_id')
            ->join('produits', 'commande_produit.produit_id', '=', 'produits.id')
            ->selectRaw('produits.nom as name, SUM(commande_produit.quantite) as total_quantite')
            ->groupBy('produits.id', 'produits.nom')
            ->orderByDesc('total_quantite')
            ->limit(5)
            ->get();
        
        // Dernières commandes
        $dernieresCommandes = Commande::with(['table', 'user'])
                                     ->latest()
                                     ->limit(5)
                                     ->get();
        
        return view('dashboard', compact(
            'tablesTotal',
            'tablesLibres',
            'tablesOccupees',
            'commandesJour',
            'commandesEnCours',
            'caJour',
            'caSemaine',
            'produitsPopulaires',
            'dernieresCommandes'
        ));
    }
}

