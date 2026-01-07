<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class HistoriquePoint extends Model
{
    protected $table = 'historique_points';

    protected $fillable = [
        'client_id',
        'points',
        'type',
        'description',
        'commande_id',
    ];

    protected $casts = [
        'points' => 'integer',
    ];

    public function client(): BelongsTo
    {
        return $this->belongsTo(Client::class);
    }

    public function commande(): BelongsTo
    {
        return $this->belongsTo(Commande::class);
    }
}

