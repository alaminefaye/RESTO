<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Commande;
use App\Models\Paiement;
use App\Models\Table;
use App\Enums\OrderStatus;
use App\Enums\TableStatus;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    /**
     * Récupérer les statistiques du tableau de bord
     * GET /api/dashboard/stats
     */
    public function stats(Request $request)
    {
        $today = now()->format('Y-m-d');

        // Chiffre d'affaires du jour (somme des paiements valides)
        $dailyRevenue = Paiement::whereDate('created_at', $today)
            ->where('statut', 'valide')
            ->sum('montant');

        // Commandes actives (non terminées et non annulées)
        $activeOrders = Commande::whereDate('created_at', $today)
            ->whereNotIn('statut', [OrderStatus::Terminee, OrderStatus::Annulee])
            ->count();

        // Tables occupées
        $occupiedTables = Table::where('statut', 'occupee')->count();
        $totalTables = Table::count();
        $occupancyRate = $totalTables > 0 ? round(($occupiedTables / $totalTables) * 100) : 0;

        // Top produits du jour
        $topProducts = DB::table('commande_produit')
            ->join('commandes', 'commande_produit.commande_id', '=', 'commandes.id')
            ->join('produits', 'commande_produit.produit_id', '=', 'produits.id')
            ->whereDate('commandes.created_at', $today)
            ->select('produits.nom', DB::raw('SUM(commande_produit.quantite) as total_vendu'))
            ->groupBy('produits.id', 'produits.nom')
            ->orderByDesc('total_vendu')
            ->limit(5)
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'daily_revenue' => $dailyRevenue,
                'active_orders' => $activeOrders,
                'occupied_tables' => $occupiedTables,
                'total_tables' => $totalTables,
                'occupancy_rate' => $occupancyRate,
                'top_products' => $topProducts,
            ],
        ]);
    }
}
