<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     * Permet de distinguer les lignes déjà servies des nouvelles (client peut ajouter des produits après un "Servi").
     */
    public function up(): void
    {
        Schema::table('commande_produit', function (Blueprint $table) {
            $table->boolean('servi')->default(false)->after('statut');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('commande_produit', function (Blueprint $table) {
            $table->dropColumn('servi');
        });
    }
};
