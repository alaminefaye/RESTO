<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Enums\ReservationStatus;
use Carbon\Carbon;

class Reservation extends Model
{
    use HasFactory;

    protected $fillable = [
        'table_id',
        'user_id',
        'nom_client',
        'telephone',
        'email',
        'date_reservation',
        'heure_debut',
        'heure_fin',
        'duree',
        'nombre_personnes',
        'prix_total',
        'acompte',
        'statut',
        'notes',
    ];

    protected $casts = [
        'date_reservation' => 'date',
        'heure_debut' => 'datetime:H:i',
        'heure_fin' => 'datetime:H:i',
        'duree' => 'integer',
        'nombre_personnes' => 'integer',
        'prix_total' => 'decimal:2',
        'acompte' => 'decimal:2',
        'statut' => ReservationStatus::class,
    ];

    /**
     * Relation avec la table
     */
    public function table()
    {
        return $this->belongsTo(Table::class);
    }

    /**
     * Relation avec l'utilisateur (client)
     */
    public function user()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Vérifier si la réservation est confirmée
     */
    public function isConfirmee(): bool
    {
        return $this->statut === ReservationStatus::Confirmee;
    }

    /**
     * Confirmer la réservation
     */
    public function confirmer(): void
    {
        $this->statut = ReservationStatus::Confirmee;
        $this->save();
        
        // Marquer la table comme réservée
        if ($this->table) {
            $this->table->reserver();
        }
    }

    /**
     * Annuler la réservation
     */
    public function annuler(): void
    {
        $this->statut = ReservationStatus::Annulee;
        $this->save();
        
        // Libérer la table si elle était réservée pour cette réservation
        if ($this->table && $this->table->statut->value === 'reservee') {
            // Vérifier qu'il n'y a pas d'autres réservations actives pour cette table
            $hasOtherReservations = self::where('table_id', $this->table_id)
                ->where('id', '!=', $this->id)
                ->whereIn('statut', [
                    ReservationStatus::Attente->value,
                    ReservationStatus::Confirmee->value,
                    ReservationStatus::EnCours->value,
                ])
                ->whereDate('date_reservation', $this->date_reservation)
                ->exists();
            
            if (!$hasOtherReservations) {
                $this->table->liberer();
            }
        }
    }

    /**
     * Marquer la réservation comme en cours
     */
    public function marquerEnCours(): void
    {
        $this->statut = ReservationStatus::EnCours;
        $this->save();
        
        // Marquer la table comme occupée
        if ($this->table) {
            $this->table->occuper();
        }
    }

    /**
     * Terminer la réservation
     */
    public function terminer(): void
    {
        $this->statut = ReservationStatus::Terminee;
        $this->save();
        
        // Libérer la table
        if ($this->table) {
            $this->table->liberer();
        }
    }

    /**
     * Calculer le prix total selon la durée et le type de table
     */
    public function calculerPrix(): float
    {
        if (!$this->table) {
            return 0;
        }

        $prixParHeure = $this->table->prix_par_heure ?? 0;
        $prixFixe = $this->table->prix ?? 0;

        if ($prixParHeure > 0) {
            return $prixParHeure * $this->duree;
        }

        return $prixFixe;
    }

    /**
     * Accessor pour le statut affiché
     */
    public function getStatutDisplayAttribute(): string
    {
        return match($this->statut) {
            ReservationStatus::Attente => 'En attente',
            ReservationStatus::Confirmee => 'Confirmée',
            ReservationStatus::EnCours => 'En cours',
            ReservationStatus::Terminee => 'Terminée',
            ReservationStatus::Annulee => 'Annulée',
        };
    }

    /**
     * Scope pour les réservations à venir
     */
    public function scopeAVenir($query)
    {
        return $query->where('date_reservation', '>=', now()->toDateString())
                     ->whereIn('statut', [
                         ReservationStatus::Attente->value,
                         ReservationStatus::Confirmee->value,
                     ]);
    }

    /**
     * Scope pour les réservations du jour
     */
    public function scopeDuJour($query)
    {
        return $query->whereDate('date_reservation', today());
    }

    /**
     * Scope par statut
     */
    public function scopeOfStatut($query, $statut)
    {
        return $query->where('statut', $statut);
    }
}
