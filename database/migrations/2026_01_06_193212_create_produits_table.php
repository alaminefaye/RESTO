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
        Schema::create('produits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('categorie_id')->constrained('categories')->onDelete('cascade');
            $table->string('nom');
            $table->text('description')->nullable();
            $table->decimal('prix', 10, 2);
            $table->string('image')->nullable(); // Chemin vers l'image
            $table->boolean('disponible')->default(true); // En stock / rupture
            $table->boolean('actif')->default(true); // Activé / désactivé
            $table->timestamps();
            
            $table->index('categorie_id');
            $table->index('disponible');
            $table->index('actif');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('produits');
    }
};
