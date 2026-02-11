<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Reservation;
use App\Models\Table;
use App\Enums\ReservationStatus;
use App\Enums\TableStatus;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Carbon\Carbon;

class ReservationController extends Controller
{
    /**
     * Liste des réservations
     * GET /api/reservations
     */
    public function index(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();
        $query = Reservation::with(['table', 'user']);

        // Si l'utilisateur est un client, filtrer par ses réservations uniquement
        if ($user->hasRole('client')) {
            $query->where('user_id', $user->id);
        }

        // Filtres
        if ($request->has('table_id')) {
            $query->where('table_id', $request->table_id);
        }

        if ($request->has('statut')) {
            $query->ofStatut($request->statut);
        }

        if ($request->has('date')) {
            $query->whereDate('date_reservation', $request->date);
        }

        if ($request->has('a_venir') && $request->boolean('a_venir')) {
            $query->aVenir();
        }

        $reservations = $query->orderBy('date_reservation', 'desc')
                             ->orderBy('heure_debut', 'desc')
                             ->get();

        return response()->json([
            'success' => true,
            'data' => $reservations->map(fn($r) => $this->formatReservation($r)),
        ]);
    }

    /**
     * Vérifier la disponibilité d'une table
     * POST /api/reservations/verifier-disponibilite
     */
    public function verifierDisponibilite(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'table_id' => 'required|exists:tables,id',
            'date_reservation' => 'required|date|after_or_equal:today',
            'heure_debut' => 'required|date_format:H:i',
            'duree' => 'required|integer|min:1',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        $table = Table::findOrFail($request->table_id);
        $dateReservation = Carbon::parse($request->date_reservation);
        $heureDebut = Carbon::parse($request->heure_debut);
        $duree = $request->duree;
        $heureFin = $heureDebut->copy()->addHours($duree);

        // Vérifier si la table est libre ou réservée
        if ($table->statut === TableStatus::Occupee) {
            return response()->json([
                'success' => false,
                'disponible' => false,
                'message' => 'La table est actuellement occupée',
            ]);
        }

        // Vérifier les conflits de réservation
        $conflits = Reservation::where('table_id', $table->id)
            ->whereDate('date_reservation', $dateReservation->toDateString())
            ->whereIn('statut', [
                ReservationStatus::Attente->value,
                ReservationStatus::Confirmee->value,
                ReservationStatus::EnCours->value,
            ])
            ->where(function($query) use ($heureDebut, $heureFin) {
                $query->where(function($q) use ($heureDebut, $heureFin) {
                    // La réservation commence pendant une autre réservation
                    $q->where('heure_debut', '<=', $heureDebut->format('H:i'))
                      ->whereRaw("ADDTIME(heure_debut, CONCAT(duree, ':00:00')) > ?", [$heureDebut->format('H:i')]);
                })->orWhere(function($q) use ($heureDebut, $heureFin) {
                    // La réservation se termine pendant une autre réservation
                    $q->where('heure_debut', '<', $heureFin->format('H:i'))
                      ->whereRaw("ADDTIME(heure_debut, CONCAT(duree, ':00:00')) >= ?", [$heureFin->format('H:i')]);
                })->orWhere(function($q) use ($heureDebut, $heureFin) {
                    // La réservation englobe une autre réservation
                    $q->where('heure_debut', '>=', $heureDebut->format('H:i'))
                      ->whereRaw("ADDTIME(heure_debut, CONCAT(duree, ':00:00')) <= ?", [$heureFin->format('H:i')]);
                });
            })
            ->exists();

        if ($conflits) {
            return response()->json([
                'success' => false,
                'disponible' => false,
                'message' => 'La table n\'est pas disponible à cette heure',
            ]);
        }

        // Calculer le prix
        $prixParHeure = $table->prix_par_heure ?? 0;
        $prixFixe = $table->prix ?? 0;
        $prixTotal = $prixParHeure > 0 ? $prixParHeure * $duree : $prixFixe;

        return response()->json([
            'success' => true,
            'disponible' => true,
            'prix_total' => $prixTotal,
            'message' => 'La table est disponible',
        ]);
    }

    /**
     * Créer une réservation
     * POST /api/reservations
     */
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'table_id' => 'required|exists:tables,id',
            'nom_client' => 'required|string|max:255',
            'telephone' => 'required|string|max:20',
            'date_reservation' => 'required|date|after_or_equal:today',
            'heure_debut' => 'required|date_format:H:i',
            'duree' => 'required|integer|min:1|max:12',
            'nombre_personnes' => 'required|integer|min:1',
            'acompte' => 'nullable|numeric|min:0',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Erreur de validation',
                'errors' => $validator->errors(),
            ], 422);
        }

        DB::beginTransaction();
        try {
            $table = Table::findOrFail($request->table_id);
            
            // Vérifier la disponibilité
            $dateReservation = Carbon::parse($request->date_reservation);
            $heureDebut = Carbon::parse($request->heure_debut);
            $duree = $request->duree;
            $heureFin = $heureDebut->copy()->addHours($duree);

            $conflits = Reservation::where('table_id', $table->id)
                ->whereDate('date_reservation', $dateReservation->toDateString())
                ->whereIn('statut', [
                    ReservationStatus::Attente->value,
                    ReservationStatus::Confirmee->value,
                    ReservationStatus::EnCours->value,
                ])
                ->where(function($query) use ($heureDebut, $heureFin) {
                    $query->where(function($q) use ($heureDebut, $heureFin) {
                        $q->where('heure_debut', '<=', $heureDebut->format('H:i'))
                          ->whereRaw("ADDTIME(heure_debut, CONCAT(duree, ':00:00')) > ?", [$heureDebut->format('H:i')]);
                    })->orWhere(function($q) use ($heureDebut, $heureFin) {
                        $q->where('heure_debut', '<', $heureFin->format('H:i'))
                          ->whereRaw("ADDTIME(heure_debut, CONCAT(duree, ':00:00')) >= ?", [$heureFin->format('H:i')]);
                    });
                })
                ->exists();

            if ($conflits) {
                DB::rollBack();
                return response()->json([
                    'success' => false,
                    'message' => 'La table n\'est pas disponible à cette heure',
                ], 400);
            }

            // Calculer le prix
            $prixParHeure = $table->prix_par_heure ?? 0;
            $prixFixe = $table->prix ?? 0;
            $prixTotal = $prixParHeure > 0 ? $prixParHeure * $duree : $prixFixe;

            // Créer la réservation
            /** @var \App\Models\User $user */
            $user = Auth::user();
            
            $reservation = Reservation::create([
                'table_id' => $request->table_id,
                'user_id' => $user->id,
                'nom_client' => $request->nom_client,
                'telephone' => $request->telephone,
                'date_reservation' => $dateReservation->toDateString(),
                'heure_debut' => $heureDebut->format('H:i'),
                'heure_fin' => $heureFin->format('H:i'),
                'duree' => $duree,
                'nombre_personnes' => $request->nombre_personnes,
                'prix_total' => $prixTotal,
                'acompte' => $request->acompte,
                'statut' => ReservationStatus::Attente,
                'notes' => $request->notes,
            ]);

            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Réservation créée avec succès',
                'data' => $this->formatReservation($reservation->fresh()->load(['table', 'user'])),
            ], 201);

        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json([
                'success' => false,
                'message' => 'Erreur lors de la création de la réservation',
                'error' => config('app.debug') ? $e->getMessage() : 'Erreur interne du serveur',
            ], 500);
        }
    }

    /**
     * Afficher une réservation
     * GET /api/reservations/{id}
     */
    public function show($id)
    {
        $reservation = Reservation::with(['table', 'user'])->find($id);

        if (!$reservation) {
            return response()->json([
                'success' => false,
                'message' => 'Réservation non trouvée',
            ], 404);
        }

        // Vérifier que l'utilisateur peut voir cette réservation
        /** @var \App\Models\User $user */
        $user = Auth::user();
        if ($user->hasRole('client') && $reservation->user_id != $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'êtes pas autorisé à voir cette réservation',
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $this->formatReservation($reservation),
        ]);
    }

    /**
     * Confirmer une réservation
     * PATCH /api/reservations/{id}/confirmer
     */
    public function confirmer($id)
    {
        $reservation = Reservation::with('table')->find($id);

        if (!$reservation) {
            return response()->json([
                'success' => false,
                'message' => 'Réservation non trouvée',
            ], 404);
        }

        if ($reservation->statut !== ReservationStatus::Attente) {
            return response()->json([
                'success' => false,
                'message' => 'Seules les réservations en attente peuvent être confirmées',
            ], 400);
        }

        $reservation->confirmer();

        return response()->json([
            'success' => true,
            'message' => 'Réservation confirmée avec succès',
            'data' => $this->formatReservation($reservation->fresh()->load(['table', 'user'])),
        ]);
    }

    /**
     * Annuler une réservation
     * PATCH /api/reservations/{id}/annuler
     */
    public function annuler($id)
    {
        $reservation = Reservation::with('table')->find($id);

        if (!$reservation) {
            return response()->json([
                'success' => false,
                'message' => 'Réservation non trouvée',
            ], 404);
        }

        // Vérifier que l'utilisateur peut annuler cette réservation
        /** @var \App\Models\User $user */
        $user = Auth::user();
        if ($user->hasRole('client') && $reservation->user_id != $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Vous n\'êtes pas autorisé à annuler cette réservation',
            ], 403);
        }

        $reservation->annuler();

        return response()->json([
            'success' => true,
            'message' => 'Réservation annulée avec succès',
            'data' => $this->formatReservation($reservation->fresh()->load(['table', 'user'])),
        ]);
    }

    /**
     * Formater une réservation pour la réponse
     */
    private function formatReservation(Reservation $reservation): array
    {
        return [
            'id' => $reservation->id,
            'table' => $reservation->table ? [
                'id' => $reservation->table->id,
                'numero' => $reservation->table->numero,
                'type' => $reservation->table->type instanceof \App\Enums\TableType 
                    ? $reservation->table->type->value 
                    : $reservation->table->type,
                'type_display' => $reservation->table->type_display,
                'capacite' => $reservation->table->capacite,
                'prix' => $reservation->table->prix ? (float) $reservation->table->prix : null,
                'prix_par_heure' => $reservation->table->prix_par_heure ? (float) $reservation->table->prix_par_heure : null,
            ] : null,
            'user' => $reservation->user ? [
                'id' => $reservation->user->id,
                'name' => $reservation->user->name,
            ] : null,
            'nom_client' => $reservation->nom_client,
            'telephone' => $reservation->telephone,
            'email' => $reservation->email,
            'date_reservation' => $reservation->date_reservation->format('Y-m-d'),
            'heure_debut' => $reservation->heure_debut->format('H:i'),
            'heure_fin' => $reservation->heure_fin ? $reservation->heure_fin->format('H:i') : null,
            'duree' => $reservation->duree,
            'nombre_personnes' => $reservation->nombre_personnes,
            'prix_total' => (float) $reservation->prix_total,
            'acompte' => $reservation->acompte ? (float) $reservation->acompte : null,
            'statut' => $reservation->statut->value,
            'statut_display' => $reservation->statut_display,
            'notes' => $reservation->notes,
            'created_at' => $reservation->created_at->toIso8601String(),
            'updated_at' => $reservation->updated_at->toIso8601String(),
        ];
    }
}
