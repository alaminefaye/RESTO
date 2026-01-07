<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Facades\Storage;

class Facture extends Model
{
    use HasFactory;

    protected $fillable = [
        'commande_id',
        'paiement_id',
        'numero_facture',
        'montant_total',
        'montant_taxe',
        'fichier_pdf',
    ];

    protected $casts = [
        'montant_total' => 'decimal:2',
        'montant_taxe' => 'decimal:2',
    ];

    protected $appends = ['pdf_url'];

    public function commande(): BelongsTo
    {
        return $this->belongsTo(Commande::class);
    }

    public function paiement(): BelongsTo
    {
        return $this->belongsTo(Paiement::class);
    }

    // Accessor for PDF URL
    public function getPdfUrlAttribute(): ?string
    {
        return $this->fichier_pdf ? Storage::url($this->fichier_pdf) : null;
    }

    // Generate unique invoice number
    public static function genererNumeroFacture(): string
    {
        $date = now()->format('Ymd');
        $lastFacture = self::whereDate('created_at', today())->latest()->first();
        $sequence = $lastFacture ? intval(substr($lastFacture->numero_facture, -4)) + 1 : 1;
        
        return 'FAC-' . $date . '-' . str_pad($sequence, 4, '0', STR_PAD_LEFT);
    }
}
