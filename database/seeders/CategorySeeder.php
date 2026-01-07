<?php

namespace Database\Seeders;

use App\Models\Category;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run(): void
    {
        $categories = [
            ['nom' => 'Entrées', 'description' => 'Entrées et amuse-bouches', 'ordre' => 1, 'actif' => true],
            ['nom' => 'Plats Principaux', 'description' => 'Plats traditionnels et spécialités', 'ordre' => 2, 'actif' => true],
            ['nom' => 'Grillades', 'description' => 'Viandes et poissons grillés', 'ordre' => 3, 'actif' => true],
            ['nom' => 'Boissons Chaudes', 'description' => 'Café, thé, infusions', 'ordre' => 4, 'actif' => true],
            ['nom' => 'Boissons Froides', 'description' => 'Jus, sodas, eau', 'ordre' => 5, 'actif' => true],
            ['nom' => 'Desserts', 'description' => 'Desserts et pâtisseries', 'ordre' => 6, 'actif' => true],
        ];

        foreach ($categories as $category) {
            Category::firstOrCreate(['nom' => $category['nom']], $category);
        }

        $this->command->info('✓ ' . count($categories) . ' catégories créées');
    }
}
