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
            ['nom' => 'Accompagnements', 'description' => 'Riz, frites, légumes', 'ordre' => 4, 'actif' => true],
            ['nom' => 'Sauces', 'description' => 'Sauces et condiments', 'ordre' => 5, 'actif' => true],
            ['nom' => 'Boissons Chaudes', 'description' => 'Café, thé, infusions', 'ordre' => 6, 'actif' => true],
            ['nom' => 'Boissons Froides', 'description' => 'Jus, sodas, eau', 'ordre' => 7, 'actif' => true],
            ['nom' => 'Boissons Alcoolisées', 'description' => 'Bières, vins, cocktails', 'ordre' => 8, 'actif' => true],
            ['nom' => 'Desserts', 'description' => 'Desserts et pâtisseries', 'ordre' => 9, 'actif' => true],
            ['nom' => 'Petits Déjeuners', 'description' => 'Petits déjeuners et brunch', 'ordre' => 10, 'actif' => true],
        ];

        foreach ($categories as $category) {
            Category::firstOrCreate(['nom' => $category['nom']], $category);
        }

        $this->command->info('✓ ' . count($categories) . ' catégories créées');
    }
}
