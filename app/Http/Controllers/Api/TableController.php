<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Table;
use App\Services\QRCodeService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

use App\Enums\ReservationStatus;

class TableController extends Controller
{
    protected $qrCodeService;

    public function __construct(QRCodeService $qrCodeService)
    {
        $this->qrCodeService = $qrCodeService;
    }

    /**
     * Liste de toutes les tables
     * GET /api/tables
     */
    public function index(Request $request)
    {
        $query = Table::query();

        // Filtres optionnels
        if ($request->has('type')) {
            $query->where('type', $request->type);
        }

        if ($request->has('statut')) {
            $query->where('statut', $request->statut);
        }

        if ($request->has('actif')) {
            $query->where('actif', $request->boolean('actif'));
        }

        $tables = $query->orderBy('numero')->get();

        return response()->json([
            'success' => true,
            'data' => $tables->map(function ($table) {
                return $this->formatTable($table);
            }),
        ]);
    }

    /**
     * Créer une nouvelle table
     * POST /api/tables
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'numero' => 'required|string|unique:tables,numero',
            'type' => 'required|in:simple,vip,espace_jeux',
            'capacite' => 'required|integer|min:1',
            'prix' => 'nullable|numeric|min:0',
            'prix_par_heure' => 'nullable|numeric|min:0',
            'actif' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        $table = Table::create($validator->validated());

        // Générer le QR Code
        $qrCodePath = $this->qrCodeService->generateForTable($table);
        $table->update(['qr_code' => $qrCodePath]);

        return response()->json([
            'success' => true,
            'message' => 'Table créée avec succès',
            'data' => $this->formatTable($table->fresh()),
        ], 201);
    }

    /**
     * Afficher une table spécifique
     * GET /api/tables/{id}
     */
    public function show($id)
    {
        $table = Table::find($id);

        if (!$table) {
            return response()->json([
                'success' => false,
                'message' => 'Table non trouvée',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $this->formatTable($table),
        ]);
    }

    /**
     * Mettre à jour une table
     * PUT/PATCH /api/tables/{id}
     */
    public function update(Request $request, $id)
    {
        $table = Table::find($id);

        if (!$table) {
            return response()->json([
                'success' => false,
                'message' => 'Table non trouvée',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'numero' => 'sometimes|string|unique:tables,numero,' . $id,
            'type' => 'sometimes|in:simple,vip,espace_jeux',
            'capacite' => 'sometimes|integer|min:1',
            'statut' => 'sometimes|in:libre,occupee,reservee,en_paiement',
            'prix' => 'nullable|numeric|min:0',
            'prix_par_heure' => 'nullable|numeric|min:0',
            'actif' => 'boolean',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        $table->update($validator->validated());

        // Régénérer le QR Code si le numéro a changé
        if ($request->has('numero')) {
            $qrCodePath = $this->qrCodeService->regenerateForTable($table);
            $table->update(['qr_code' => $qrCodePath]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Table mise à jour avec succès',
            'data' => $this->formatTable($table->fresh()),
        ]);
    }

    /**
     * Supprimer une table
     * DELETE /api/tables/{id}
     */
    public function destroy($id)
    {
        $table = Table::find($id);

        if (!$table) {
            return response()->json([
                'success' => false,
                'message' => 'Table non trouvée',
            ], 404);
        }

        // Supprimer le QR Code
        $this->qrCodeService->deleteForTable($table);

        $table->delete();

        return response()->json([
            'success' => true,
            'message' => 'Table supprimée avec succès',
        ]);
    }

    /**
     * Changer le statut d'une table
     * PATCH /api/tables/{id}/statut
     */
    public function updateStatut(Request $request, $id)
    {
        $table = Table::find($id);

        if (!$table) {
            return response()->json([
                'success' => false,
                'message' => 'Table non trouvée',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'statut' => 'required|in:libre,occupee,reservee,en_paiement',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        $table->changerStatut($request->statut);

        return response()->json([
            'success' => true,
            'message' => 'Statut mis à jour avec succès',
            'data' => $this->formatTable($table->fresh()),
        ]);
    }

    /**
     * Obtenir le QR Code d'une table
     * GET /api/tables/{id}/qrcode
     */
    public function getQRCode($id)
    {
        $table = Table::find($id);

        if (!$table) {
            return response()->json([
                'success' => false,
                'message' => 'Table non trouvée',
            ], 404);
        }

        $qrCodeContent = $this->qrCodeService->getQRCodeContent($table);

        return response($qrCodeContent, 200)
            ->header('Content-Type', 'image/svg+xml');
    }

    /**
     * Obtenir les informations de la table pour le menu (endpoint du QR code)
     * GET /api/tables/{id}/menu
     */
    public function getMenuForTable($id)
    {
        try {
            $table = Table::find($id);

            if (!$table) {
                return response()->json([
                    'success' => false,
                    'message' => 'Table introuvable (ID: ' . $id . '). Vérifiez le QR code scanné.',
                    'error' => 'Table not found',
                ], 404);
            }

            // Retourner les informations de la table pour que l'application mobile
            // puisse charger le menu avec le table_id
            return response()->json([
                'success' => true,
                'message' => 'Table trouvée',
                'data' => [
                    'table' => $this->formatTable($table),
                    'menu_url' => config('app.url') . '/api/produits?categorie_id=',
                    'table_id' => $table->id,
                    'table_numero' => $table->numero,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur: ' . $e->getMessage(),
                'error' => 'Exception: Table introuvable (ID: ' . $id . '). Vérifiez le QR code scanné: ' . request()->url(),
            ], 500);
        }
    }

    /**
     * Régénérer le QR Code d'une table
     * POST /api/tables/{id}/regenerate-qrcode
     */
    public function regenerateQRCode($id)
    {
        $table = Table::find($id);

        if (!$table) {
            return response()->json([
                'success' => false,
                'message' => 'Table non trouvée',
            ], 404);
        }

        $qrCodePath = $this->qrCodeService->regenerateForTable($table);
        $table->update(['qr_code' => $qrCodePath]);

        return response()->json([
            'success' => true,
            'message' => 'QR Code régénéré avec succès',
            'data' => $this->formatTable($table->fresh()),
        ]);
    }

    /**
     * Obtenir les tables libres
     * GET /api/tables/libres
     */
    public function libres()
    {
        $tables = Table::libres()->actives()->orderBy('numero')->get();

        return response()->json([
            'success' => true,
            'data' => $tables->map(function ($table) {
                return $this->formatTable($table);
            }),
        ]);
    }

    /**
     * Formater les données d'une table pour la réponse
     */
    private function formatTable(Table $table): array
    {
        $reservationActuelle = null;
        if ($table->statut === \App\Enums\TableStatus::Reservee) {
            $reservationActuelle = $table->reservations()
                ->where('date_reservation', '>=', now()->toDateString())
                ->whereIn('statut', [
                    ReservationStatus::Attente->value, 
                    ReservationStatus::Confirmee->value,
                    ReservationStatus::EnCours->value
                ])
                ->orderBy('date_reservation')
                ->orderBy('heure_debut')
                ->first();
        }

        return [
            'id' => $table->id,
            'numero' => $table->numero,
            'type' => $table->type->value ?? $table->type,
            'type_display' => $table->type_display,
            'capacite' => $table->capacite,
            'statut' => $table->statut->value ?? $table->statut,
            'statut_display' => $table->statut_display,
            'prix' => $table->prix,
            'prix_par_heure' => $table->prix_par_heure,
            'qr_code' => $table->qr_code,
            'qr_code_url' => $table->qr_code_url,
            'actif' => $table->actif,
            'created_at' => $table->created_at?->toISOString(),
            'updated_at' => $table->updated_at?->toISOString(),
            'reservation_actuelle' => $reservationActuelle ? [
                'id' => $reservationActuelle->id,
                'nom_client' => $reservationActuelle->nom_client,
                'telephone' => $reservationActuelle->telephone,
                'date_reservation' => $reservationActuelle->date_reservation,
                'heure_debut' => $reservationActuelle->heure_debut,
                'heure_fin' => $reservationActuelle->heure_fin,
                'nombre_personnes' => $reservationActuelle->nombre_personnes,
                'notes' => $reservationActuelle->notes,
            ] : null,
        ];
    }
}
