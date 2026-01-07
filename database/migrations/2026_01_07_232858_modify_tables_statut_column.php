<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Modifier la colonne enum pour remplacer 'paiement' par 'en_paiement'
        // MySQL nécessite une requête SQL brute pour modifier un enum
        DB::statement("ALTER TABLE `tables` MODIFY COLUMN `statut` ENUM('libre', 'occupee', 'reservee', 'en_paiement') DEFAULT 'libre'");
        
        // Si des enregistrements ont encore 'paiement', les mettre à jour vers 'en_paiement'
        DB::table('tables')
            ->where('statut', 'paiement')
            ->update(['statut' => 'en_paiement']);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Revenir à l'ancienne valeur si nécessaire
        DB::statement("ALTER TABLE `tables` MODIFY COLUMN `statut` ENUM('libre', 'occupee', 'reservee', 'paiement') DEFAULT 'libre'");
    }
};
