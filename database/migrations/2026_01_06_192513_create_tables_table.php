<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('tables', function (Blueprint $table) {
            $table->id();
            $table->string('numero')->unique(); // Numéro de la table (ex: T1, T2, VIP1, etc.)
            $table->enum('type', ['simple', 'vip', 'espace_jeux'])->default('simple');
            $table->integer('capacite')->default(4); // Nombre de places
            $table->enum('statut', ['libre', 'occupee', 'reservee', 'en_paiement'])->default('libre');
            $table->decimal('prix', 10, 2)->nullable(); // Prix pour tables VIP (fixe)
            $table->decimal('prix_par_heure', 10, 2)->nullable(); // Prix par heure pour espaces jeux
            $table->string('qr_code')->nullable(); // Chemin vers le fichier QR Code
            $table->boolean('actif')->default(true); // Table active ou désactivée
            $table->timestamps();
            
            // Index pour améliorer les performances
            $table->index('type');
            $table->index('statut');
            $table->index('actif');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('tables');
    }
};
