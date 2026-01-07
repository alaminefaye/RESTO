<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    public function up(): void
    {
        // Vérifier si l'ancienne table roles existe sans guard_name
        if (Schema::hasTable('roles')) {
            $columns = Schema::getColumnListing('roles');
            
            // Si la table n'a pas la colonne guard_name, c'est l'ancienne table
            if (!in_array('guard_name', $columns)) {
                // Supprimer les tables pivot liées si elles existent
                if (Schema::hasTable('role_user')) {
                    Schema::drop('role_user');
                }
                if (Schema::hasTable('permission_role')) {
                    Schema::drop('permission_role');
                }
                
                // Supprimer l'ancienne table roles
                Schema::drop('roles');
            }
        }
        
        // Vérifier et supprimer l'ancienne table permissions si elle existe sans guard_name
        if (Schema::hasTable('permissions')) {
            $columns = Schema::getColumnListing('permissions');
            
            // Si la table n'a pas la colonne guard_name, c'est l'ancienne table
            if (!in_array('guard_name', $columns)) {
                // Supprimer les tables pivot liées si elles existent
                if (Schema::hasTable('permission_role')) {
                    Schema::drop('permission_role');
                }
                if (Schema::hasTable('user_permissions')) {
                    Schema::drop('user_permissions');
                }
                
                // Supprimer l'ancienne table permissions
                Schema::drop('permissions');
            }
        }
    }

    public function down(): void
    {
        // Cette migration ne peut pas être annulée car on supprime des tables obsolètes
    }
};
