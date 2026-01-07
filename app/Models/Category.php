<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Category extends Model
{
    protected $fillable = [
        'nom',
        'description',
        'ordre',
        'actif',
    ];

    protected $casts = [
        'ordre' => 'integer',
        'actif' => 'boolean',
    ];

    /**
     * Une catégorie a plusieurs produits
     */
    public function produits(): HasMany
    {
        return $this->hasMany(Product::class, 'categorie_id');
    }

    /**
     * Produits actifs et disponibles de cette catégorie
     */
    public function produitsDisponibles(): HasMany
    {
        return $this->hasMany(Product::class, 'categorie_id')
            ->where('actif', true)
            ->where('disponible', true);
    }

    /**
     * Scope pour les catégories actives
     */
    public function scopeActives($query)
    {
        return $query->where('actif', true);
    }

    /**
     * Scope pour trier par ordre
     */
    public function scopeOrdered($query)
    {
        return $query->orderBy('ordre')->orderBy('nom');
    }
}
