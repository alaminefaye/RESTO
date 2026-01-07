<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use App\Enums\TableType;
use App\Enums\TableStatus;

class Table extends Model
{
    use HasFactory;

    protected $fillable = [
        'numero',
        'type',
        'capacite',
        'statut',
        'prix',
        'prix_par_heure',
        'qr_code',
        'actif',
    ];

    protected $casts = [
        'type' => TableType::class,
        'statut' => TableStatus::class,
        'capacite' => 'integer',
        'prix' => 'decimal:2',
        'prix_par_heure' => 'decimal:2',
        'actif' => 'boolean',
    ];

    protected $appends = ['qr_code_url'];

    /**
     * Vérifier si la table est libre
     */
    public function isLibre(): bool
    {
        return $this->statut === TableStatus::Libre;
    }

    /**
     * Marquer comme occupée
     */
    public function occuper(): void
    {
        $this->statut = TableStatus::Occupee;
        $this->save();
    }

    /**
     * Libérer la table
     */
    public function liberer(): void
    {
        $this->statut = TableStatus::Libre;
        $this->save();
    }

    /**
     * Marquer comme réservée
     */
    public function reserver(): void
    {
        $this->statut = TableStatus::Reservee;
        $this->save();
    }

    /**
     * Marquer en cours de paiement
     */
    public function enPaiement(): void
    {
        $this->statut = TableStatus::EnPaiement;
        $this->save();
    }

    /**
     * Accessor pour l'URL complète du QR Code
     */
    public function getQrCodeUrlAttribute(): ?string
    {
        if (!$this->qr_code) {
            return null;
        }
        
        return asset('storage/' . $this->qr_code);
    }

    /**
     * Scope pour les tables actives
     */
    public function scopeActives($query)
    {
        return $query->where('actif', true);
    }

    /**
     * Relation avec les commandes
     */
    public function commandes()
    {
        return $this->hasMany(Commande::class);
    }
}
