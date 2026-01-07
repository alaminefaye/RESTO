<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('clients', function (Blueprint $table) {
            $table->id();
            $table->string('nom');
            $table->string('prenom');
            $table->string('telephone')->unique();
            $table->string('email')->nullable()->unique();
            $table->date('date_naissance')->nullable();
            $table->text('adresse')->nullable();
            $table->integer('points_fidelite')->default(0);
            $table->decimal('total_depenses', 10, 2)->default(0);
            $table->integer('nombre_visites')->default(0);
            $table->date('date_derniere_visite')->nullable();
            $table->date('date_inscription')->useCurrent();
            $table->boolean('actif')->default(true);
            $table->timestamps();
            
            $table->index('telephone');
            $table->index('email');
            $table->index('points_fidelite');
        });

        // Table pour l'historique des points
        Schema::create('historique_points', function (Blueprint $table) {
            $table->id();
            $table->foreignId('client_id')->constrained('clients')->onDelete('cascade');
            $table->integer('points');
            $table->enum('type', ['gain', 'depense', 'ajustement']);
            $table->string('description');
            $table->foreignId('commande_id')->nullable()->constrained('commandes')->onDelete('set null');
            $table->timestamps();
            
            $table->index('client_id');
            $table->index('type');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('historique_points');
        Schema::dropIfExists('clients');
    }
};
