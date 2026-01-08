<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Support\Facades\Storage;

class Product extends Model
{
    protected $table = 'produits';

    protected $fillable = [
        'categorie_id',
        'nom',
        'description',
        'prix',
        'image',
        'disponible',
        'actif',
    ];

    protected $casts = [
        'categorie_id' => 'integer',
        'prix' => 'decimal:2',
        'disponible' => 'boolean',
        'actif' => 'boolean',
    ];

    /**
     * Un produit appartient à une catégorie
     */
    public function categorie(): BelongsTo
    {
        return $this->belongsTo(Category::class, 'categorie_id');
    }

    /**
     * Un produit peut être dans plusieurs commandes
     */
    public function commandes(): BelongsToMany
    {
        return $this->belongsToMany(Commande::class, 'commande_produit')
            ->withPivot('quantite', 'prix_unitaire', 'notes')
            ->withTimestamps();
    }

    /**
     * Obtenir l'URL complète de l'image
     */
    public function getImageUrlAttribute(): ?string
    {
        if (!$this->image) {
            return null;
        }

        // Si le chemin commence par "public/", on l'enlève
        $path = str_starts_with($this->image, 'public/') 
            ? substr($this->image, 7) // Enlève "public/"
            : $this->image;

        // Retourner un chemin relatif qui fonctionne avec le domaine actuel
        // Le navigateur résoudra automatiquement l'URL complète
        return '/storage/' . $path;
    }

    /**
     * Scope pour les produits disponibles
     */
    public function scopeDisponibles($query)
    {
        return $query->where('disponible', true);
    }

    /**
     * Scope pour les produits actifs
     */
    public function scopeActifs($query)
    {
        return $query->where('actif', true);
    }

    /**
     * Scope pour filtrer par catégorie
     */
    public function scopeOfCategorie($query, int $categorieId)
    {
        return $query->where('categorie_id', $categorieId);
    }

    /**
     * Vérifier si le produit est disponible
     */
    public function isDisponible(): bool
    {
        return $this->actif && $this->disponible;
    }
}
