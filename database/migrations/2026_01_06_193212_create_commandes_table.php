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
        Schema::create('commandes', function (Blueprint $table) {
            $table->id();
            $table->foreignId('table_id')->constrained('tables')->onDelete('cascade');
            $table->foreignId('user_id')->nullable()->constrained('users')->onDelete('set null'); // Serveur/Caissier qui a créé
            $table->enum('statut', ['attente', 'preparation', 'servie', 'terminee', 'annulee'])->default('attente');
            $table->decimal('montant_total', 10, 2)->default(0);
            $table->text('notes')->nullable(); // Notes spéciales du client
            $table->timestamps();
            
            $table->index('table_id');
            $table->index('user_id');
            $table->index('statut');
            $table->index('created_at');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('commandes');
    }
};
