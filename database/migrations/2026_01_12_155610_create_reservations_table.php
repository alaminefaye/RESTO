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
        Schema::create('reservations', function (Blueprint $table) {
            $table->id();
            $table->foreignId('table_id')->constrained('tables')->onDelete('cascade');
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null');
            $table->string('nom_client');
            $table->string('telephone');
            $table->string('email')->nullable();
            $table->date('date_reservation');
            $table->time('heure_debut');
            $table->time('heure_fin')->nullable();
            $table->integer('duree')->default(1); // Durée en heures
            $table->integer('nombre_personnes');
            $table->decimal('prix_total', 10, 2)->default(0);
            $table->decimal('acompte', 10, 2)->nullable();
            $table->string('statut')->default('attente'); // attente, confirmee, en_cours, terminee, annulee
            $table->text('notes')->nullable();
            $table->timestamps();
            
            // Index pour améliorer les performances
            $table->index('date_reservation');
            $table->index('statut');
            $table->index(['table_id', 'date_reservation']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reservations');
    }
};
