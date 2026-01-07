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
        Schema::create('paiements', function (Blueprint $table) {
            $table->id();
            $table->foreignId('commande_id')->constrained('commandes')->onDelete('cascade');
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null'); // Caissier
            $table->decimal('montant', 10, 2);
            $table->enum('moyen_paiement', ['especes', 'wave', 'orange_money', 'carte_bancaire'])->default('especes');
            $table->enum('statut', ['en_attente', 'valide', 'echoue', 'annule'])->default('en_attente');
            $table->string('transaction_id')->nullable(); // Pour mobile money
            $table->decimal('montant_recu', 10, 2)->nullable(); // Pour espèces
            $table->decimal('monnaie_rendue', 10, 2)->nullable()->default(0);
            $table->text('notes')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('paiements');
    }
};
