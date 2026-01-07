<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;

class Role extends Model
{
    protected $fillable = [
        'name',
        'display_name',
        'description',
    ];

    /**
     * Un rôle appartient à plusieurs utilisateurs
     */
    public function users(): BelongsToMany
    {
        return $this->belongsToMany(User::class);
    }

    /**
     * Un rôle a plusieurs permissions
     */
    public function permissions(): BelongsToMany
    {
        return $this->belongsToMany(Permission::class);
    }

    /**
     * Attacher une permission au rôle
     */
    public function givePermissionTo(Permission|string $permission): self
    {
        if (is_string($permission)) {
            $permission = Permission::where('name', $permission)->firstOrFail();
        }

        $this->permissions()->syncWithoutDetaching($permission);

        return $this;
    }

    /**
     * Retirer une permission du rôle
     */
    public function revokePermissionTo(Permission|string $permission): self
    {
        if (is_string($permission)) {
            $permission = Permission::where('name', $permission)->firstOrFail();
        }

        $this->permissions()->detach($permission);

        return $this;
    }

    /**
     * Vérifier si le rôle a une permission
     */
    public function hasPermission(string $permission): bool
    {
        return $this->permissions()->where('name', $permission)->exists();
    }
}
