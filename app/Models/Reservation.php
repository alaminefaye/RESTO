<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use App\Enums\ReservationStatus;
use Carbon\Carbon;

/**
 * @property int $id
 * @property int $table_id
 * @property int|null $user_id
 * @property string $nom_client
 * @property string $telephone
 * @property string|null $email
 * @property \Illuminate\Support\Carbon $date_reservation
 * @property \Illuminate\Support\Carbon $heure_debut
 * @property \Illuminate\Support\Carbon|null $heure_fin
 * @property int $duree
 * @property int $nombre_personnes
 * @property float $prix_total
 * @property float|null $acompte
 * @property ReservationStatus $statut
 * @property string|null $notes
 * @property \Illuminate\Support\Carbon|null $created_at
 * @property \Illuminate\Support\Carbon|null $updated_at
 * 
 * @property-read Table|null $table
 * @property-read User|null $user
 * @property-read string $statut_display
 */
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
        $table = $this->getAttribute('table');
        if ($table) {
            $table->reserver();
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
        $table = $this->getAttribute('table');
        if ($table && $table->statut->value === 'reservee') {
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
                $table->liberer();
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
        $table = $this->getAttribute('table');
        if ($table) {
            $table->occuper();
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
        $table = $this->getAttribute('table');
        if ($table) {
            $table->liberer();
        }
    }

    /**
     * Calculer le prix total selon la durée et le type de table
     */
    public function calculerPrix(): float
    {
        $table = $this->getAttribute('table');
        if (!$table) {
            return 0;
        }

        $prixParHeure = $table->prix_par_heure ?? 0;
        $prixFixe = $table->prix ?? 0;

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
