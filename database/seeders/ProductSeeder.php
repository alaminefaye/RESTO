<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\Product;
use Illuminate\Database\Seeder;

class ProductSeeder extends Seeder
{
    public function run(): void
    {
        $produits = [
            // Entrées
            ['categorie' => 'Entrées', 'nom' => 'Salade Dakaroise', 'description' => 'Salade fraîche avec légumes locaux', 'prix' => 2500],
            ['categorie' => 'Entrées', 'nom' => 'Pastels', 'description' => 'Beignets de poisson (x3)', 'prix' => 1500],
            ['categorie' => 'Entrées', 'nom' => 'Nems', 'description' => 'Nems aux légumes (x4)', 'prix' => 2000],
            
            // Plats Principaux
            ['categorie' => 'Plats Principaux', 'nom' => 'Thiéboudienne', 'description' => 'Riz au poisson, légumes', 'prix' => 4500],
            ['categorie' => 'Plats Principaux', 'nom' => 'Mafé', 'description' => 'Sauce d\'arachide avec viande', 'prix' => 4000],
            ['categorie' => 'Plats Principaux', 'nom' => 'Yassa Poulet', 'description' => 'Poulet mariné aux oignons', 'prix' => 4500],
            ['categorie' => 'Plats Principaux', 'nom' => 'Domoda', 'description' => 'Ragoût de viande sauce tomate', 'prix' => 4000],
            
            // Grillades
            ['categorie' => 'Grillades', 'nom' => 'Poulet Braisé', 'description' => 'Poulet grillé entier', 'prix' => 5500],
            ['categorie' => 'Grillades', 'nom' => 'Poisson Braisé', 'description' => 'Poisson frais grillé', 'prix' => 6000],
            ['categorie' => 'Grillades', 'nom' => 'Dibi (Mouton)', 'description' => 'Viande de mouton grillée', 'prix' => 7000],
            
            // Boissons Chaudes
            ['categorie' => 'Boissons Chaudes', 'nom' => 'Café Touba', 'description' => 'Café épicé traditionnel', 'prix' => 500],
            ['categorie' => 'Boissons Chaudes', 'nom' => 'Thé Attaya', 'description' => 'Thé à la menthe', 'prix' => 1000],
            ['categorie' => 'Boissons Chaudes', 'nom' => 'Café Noir', 'description' => 'Expresso', 'prix' => 800],
            
            // Boissons Froides
            ['categorie' => 'Boissons Froides', 'nom' => 'Jus de Bissap', 'description' => 'Jus d\'hibiscus', 'prix' => 1000],
            ['categorie' => 'Boissons Froides', 'nom' => 'Jus de Bouye', 'description' => 'Jus de baobab', 'prix' => 1000],
            ['categorie' => 'Boissons Froides', 'nom' => 'Jus de Gingembre', 'description' => 'Jus frais au gingembre', 'prix' => 1000],
            ['categorie' => 'Boissons Froides', 'nom' => 'Eau Minérale', 'description' => 'Bouteille 1.5L', 'prix' => 500],
            ['categorie' => 'Boissons Froides', 'nom' => 'Coca-Cola', 'description' => 'Canette 33cl', 'prix' => 700],
            
            // Desserts
            ['categorie' => 'Desserts', 'nom' => 'Thiakry', 'description' => 'Couscous sucré au lait caillé', 'prix' => 1500],
            ['categorie' => 'Desserts', 'nom' => 'Sombi', 'description' => 'Crème de riz sucrée', 'prix' => 1500],
            ['categorie' => 'Desserts', 'nom' => 'Salade de Fruits', 'description' => 'Fruits frais de saison', 'prix' => 2000],
        ];

        foreach ($produits as $produitData) {
            $categorie = Category::where('nom', $produitData['categorie'])->first();
            
            if ($categorie) {
                Product::firstOrCreate(
                    [
                        'nom' => $produitData['nom'],
                        'categorie_id' => $categorie->id,
                    ],
                    [
                        'description' => $produitData['description'],
                        'prix' => $produitData['prix'],
                        'disponible' => true,
                        'actif' => true,
                    ]
                );
            }
        }

        $this->command->info('✓ ' . count($produits) . ' produits créés');
    }
}
