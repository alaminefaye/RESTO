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
            // ========== ENTREES ==========
            ['categorie' => 'Entrées', 'nom' => 'Salade Dakaroise', 'description' => 'Salade fraîche avec légumes locaux et vinaigrette', 'prix' => 2500],
            ['categorie' => 'Entrées', 'nom' => 'Pastels', 'description' => 'Beignets de poisson croustillants (x3)', 'prix' => 1500],
            ['categorie' => 'Entrées', 'nom' => 'Nems', 'description' => 'Nems aux légumes et vermicelles (x4)', 'prix' => 2000],
            ['categorie' => 'Entrées', 'nom' => 'Accras de Morue', 'description' => 'Beignets de morue épicés (x5)', 'prix' => 1800],
            ['categorie' => 'Entrées', 'nom' => 'Salade César', 'description' => 'Salade verte, croûtons, parmesan, sauce césar', 'prix' => 3000],
            ['categorie' => 'Entrées', 'nom' => 'Soupe à l\'Oignon', 'description' => 'Soupe traditionnelle gratinée', 'prix' => 2200],
            ['categorie' => 'Entrées', 'nom' => 'Avocat Crevette', 'description' => 'Demi-avocat garni de crevettes', 'prix' => 3500],
            
            // ========== PLATS PRINCIPAUX ==========
            ['categorie' => 'Plats Principaux', 'nom' => 'Thiéboudienne', 'description' => 'Riz au poisson avec légumes (poisson, carottes, chou, manioc)', 'prix' => 4500],
            ['categorie' => 'Plats Principaux', 'nom' => 'Mafé', 'description' => 'Sauce d\'arachide avec viande de bœuf et légumes', 'prix' => 4000],
            ['categorie' => 'Plats Principaux', 'nom' => 'Yassa Poulet', 'description' => 'Poulet mariné aux oignons et citron avec riz', 'prix' => 4500],
            ['categorie' => 'Plats Principaux', 'nom' => 'Domoda', 'description' => 'Ragoût de viande dans une sauce tomate épicée', 'prix' => 4000],
            ['categorie' => 'Plats Principaux', 'nom' => 'Riz au Gras', 'description' => 'Riz à la viande et légumes dans une sauce onctueuse', 'prix' => 3500],
            ['categorie' => 'Plats Principaux', 'nom' => 'Soupe Kandia', 'description' => 'Soupe au gombo avec viande ou poisson', 'prix' => 3800],
            ['categorie' => 'Plats Principaux', 'nom' => 'Thiou', 'description' => 'Sauce tomate épicée avec poisson et légumes', 'prix' => 4200],
            ['categorie' => 'Plats Principaux', 'nom' => 'Lakh', 'description' => 'Bouillie de mil avec lait caillé et sucre', 'prix' => 2500],
            ['categorie' => 'Plats Principaux', 'nom' => 'Pastilla', 'description' => 'Tarte feuilletée au poulet et amandes', 'prix' => 4800],
            ['categorie' => 'Plats Principaux', 'nom' => 'Couscous', 'description' => 'Couscous avec agneau et légumes', 'prix' => 4500],
            
            // ========== GRILLADES ==========
            ['categorie' => 'Grillades', 'nom' => 'Poulet Braisé', 'description' => 'Poulet grillé entier avec épices', 'prix' => 5500],
            ['categorie' => 'Grillades', 'nom' => 'Poisson Braisé', 'description' => 'Poisson frais grillé au charbon de bois', 'prix' => 6000],
            ['categorie' => 'Grillades', 'nom' => 'Dibi (Mouton)', 'description' => 'Viande de mouton grillée à la sénégalaise', 'prix' => 7000],
            ['categorie' => 'Grillades', 'nom' => 'Brochettes de Bœuf', 'description' => 'Brochettes de viande marinée (x4)', 'prix' => 4500],
            ['categorie' => 'Grillades', 'nom' => 'Brochettes de Poulet', 'description' => 'Brochettes de poulet épicées (x4)', 'prix' => 4000],
            ['categorie' => 'Grillades', 'nom' => 'Brochettes Mixtes', 'description' => 'Assortiment bœuf et poulet (x6)', 'prix' => 5500],
            ['categorie' => 'Grillades', 'nom' => 'Poisson Fumé', 'description' => 'Poisson fumé traditionnel avec sauce', 'prix' => 5800],
            ['categorie' => 'Grillades', 'nom' => 'Agneau Rôti', 'description' => 'Gigot d\'agneau rôti aux herbes', 'prix' => 8500],
            
            // ========== ACCOMPAGNEMENTS ==========
            ['categorie' => 'Accompagnements', 'nom' => 'Riz Blanc', 'description' => 'Riz basmati cuit à la vapeur', 'prix' => 800],
            ['categorie' => 'Accompagnements', 'nom' => 'Riz Sauce', 'description' => 'Riz avec sauce tomate légère', 'prix' => 1000],
            ['categorie' => 'Accompagnements', 'nom' => 'Frites', 'description' => 'Pommes de terre frites maison', 'prix' => 1200],
            ['categorie' => 'Accompagnements', 'nom' => 'Légumes Sautés', 'description' => 'Légumes de saison sautés', 'prix' => 1500],
            ['categorie' => 'Accompagnements', 'nom' => 'Salade Verte', 'description' => 'Salade verte fraîche avec vinaigrette', 'prix' => 1000],
            ['categorie' => 'Accompagnements', 'nom' => 'Pain', 'description' => 'Pain français ou pain local', 'prix' => 300],
            ['categorie' => 'Accompagnements', 'nom' => 'Boulettes de Riz', 'description' => 'Boulettes de riz fourrées', 'prix' => 1800],
            
            // ========== SAUCES ==========
            ['categorie' => 'Sauces', 'nom' => 'Sauce Pimentée', 'description' => 'Sauce épicée traditionnelle', 'prix' => 500],
            ['categorie' => 'Sauces', 'nom' => 'Sauce Moutarde', 'description' => 'Moutarde douce ou forte', 'prix' => 500],
            ['categorie' => 'Sauces', 'nom' => 'Ketchup', 'description' => 'Ketchup maison', 'prix' => 300],
            ['categorie' => 'Sauces', 'nom' => 'Mayonnaise', 'description' => 'Mayonnaise maison', 'prix' => 500],
            ['categorie' => 'Sauces', 'nom' => 'Sauce Yassa', 'description' => 'Sauce aux oignons et citron', 'prix' => 700],
            
            // ========== BOISSONS CHAUDES ==========
            ['categorie' => 'Boissons Chaudes', 'nom' => 'Café Touba', 'description' => 'Café épicé traditionnel sénégalais', 'prix' => 500],
            ['categorie' => 'Boissons Chaudes', 'nom' => 'Thé Attaya', 'description' => 'Thé à la menthe traditionnel (3 services)', 'prix' => 1000],
            ['categorie' => 'Boissons Chaudes', 'nom' => 'Café Noir', 'description' => 'Expresso corsé', 'prix' => 800],
            ['categorie' => 'Boissons Chaudes', 'nom' => 'Café au Lait', 'description' => 'Café avec lait chaud', 'prix' => 1000],
            ['categorie' => 'Boissons Chaudes', 'nom' => 'Cappuccino', 'description' => 'Café avec mousse de lait', 'prix' => 1500],
            ['categorie' => 'Boissons Chaudes', 'nom' => 'Chocolat Chaud', 'description' => 'Chocolat chaud crémeux', 'prix' => 1200],
            ['categorie' => 'Boissons Chaudes', 'nom' => 'Infusion Menthe', 'description' => 'Tisane à la menthe fraîche', 'prix' => 800],
            ['categorie' => 'Boissons Chaudes', 'nom' => 'Infusion Gingembre', 'description' => 'Tisane au gingembre et citron', 'prix' => 1000],
            
            // ========== BOISSONS FROIDES ==========
            ['categorie' => 'Boissons Froides', 'nom' => 'Jus de Bissap', 'description' => 'Jus d\'hibiscus frais', 'prix' => 1000],
            ['categorie' => 'Boissons Froides', 'nom' => 'Jus de Bouye', 'description' => 'Jus de baobab naturel', 'prix' => 1000],
            ['categorie' => 'Boissons Froides', 'nom' => 'Jus de Gingembre', 'description' => 'Jus frais au gingembre et citron', 'prix' => 1000],
            ['categorie' => 'Boissons Froides', 'nom' => 'Jus d\'Ananas', 'description' => 'Jus d\'ananas frais pressé', 'prix' => 1000],
            ['categorie' => 'Boissons Froides', 'nom' => 'Jus de Mangue', 'description' => 'Jus de mangue naturel', 'prix' => 1200],
            ['categorie' => 'Boissons Froides', 'nom' => 'Jus d\'Orange', 'description' => 'Jus d\'orange frais pressé', 'prix' => 1000],
            ['categorie' => 'Boissons Froides', 'nom' => 'Eau Minérale', 'description' => 'Bouteille 1.5L', 'prix' => 500],
            ['categorie' => 'Boissons Froides', 'nom' => 'Eau Gazeuse', 'description' => 'Bouteille 1L', 'prix' => 600],
            ['categorie' => 'Boissons Froides', 'nom' => 'Coca-Cola', 'description' => 'Canette 33cl', 'prix' => 700],
            ['categorie' => 'Boissons Froides', 'nom' => 'Fanta', 'description' => 'Canette 33cl', 'prix' => 700],
            ['categorie' => 'Boissons Froides', 'nom' => 'Sprite', 'description' => 'Canette 33cl', 'prix' => 700],
            ['categorie' => 'Boissons Froides', 'nom' => 'Jus Vitamalt', 'description' => 'Bouteille 25cl', 'prix' => 600],
            ['categorie' => 'Boissons Froides', 'nom' => 'Limonade', 'description' => 'Limonade locale fraîche', 'prix' => 800],
            
            // ========== BOISSONS ALCOOLISEES ==========
            ['categorie' => 'Boissons Alcoolisées', 'nom' => 'Bière Flag', 'description' => 'Bière locale 65cl', 'prix' => 1500],
            ['categorie' => 'Boissons Alcoolisées', 'nom' => 'Bière Gazelle', 'description' => 'Bière locale 65cl', 'prix' => 1500],
            ['categorie' => 'Boissons Alcoolisées', 'nom' => 'Bière Importée', 'description' => 'Heineken, Stella, etc. (65cl)', 'prix' => 2500],
            ['categorie' => 'Boissons Alcoolisées', 'nom' => 'Vin Rouge', 'description' => 'Verre de vin rouge', 'prix' => 2000],
            ['categorie' => 'Boissons Alcoolisées', 'nom' => 'Vin Blanc', 'description' => 'Verre de vin blanc', 'prix' => 2000],
            ['categorie' => 'Boissons Alcoolisées', 'nom' => 'Cocktail Maison', 'description' => 'Cocktail du jour', 'prix' => 3000],
            ['categorie' => 'Boissons Alcoolisées', 'nom' => 'Rhum Arrangé', 'description' => 'Rhum aux fruits locaux', 'prix' => 2500],
            
            // ========== DESSERTS ==========
            ['categorie' => 'Desserts', 'nom' => 'Thiakry', 'description' => 'Couscous sucré au lait caillé et fruits secs', 'prix' => 1500],
            ['categorie' => 'Desserts', 'nom' => 'Sombi', 'description' => 'Crème de riz sucrée à la vanille', 'prix' => 1500],
            ['categorie' => 'Desserts', 'nom' => 'Salade de Fruits', 'description' => 'Fruits frais de saison', 'prix' => 2000],
            ['categorie' => 'Desserts', 'nom' => 'Tiramisu', 'description' => 'Tiramisu maison', 'prix' => 2500],
            ['categorie' => 'Desserts', 'nom' => 'Mousse au Chocolat', 'description' => 'Mousse au chocolat noir', 'prix' => 2000],
            ['categorie' => 'Desserts', 'nom' => 'Tarte au Citron', 'description' => 'Tarte citron meringuée', 'prix' => 2200],
            ['categorie' => 'Desserts', 'nom' => 'Glace Vanille', 'description' => 'Boule de glace vanille', 'prix' => 1500],
            ['categorie' => 'Desserts', 'nom' => 'Glace Chocolat', 'description' => 'Boule de glace chocolat', 'prix' => 1500],
            ['categorie' => 'Desserts', 'nom' => 'Glace Mixte', 'description' => '3 boules au choix', 'prix' => 3500],
            ['categorie' => 'Desserts', 'nom' => 'Beignets', 'description' => 'Beignets sucrés (x5)', 'prix' => 1200],
            
            // ========== PETITS DEJEUNERS ==========
            ['categorie' => 'Petits Déjeuners', 'nom' => 'Petit Déjeuner Complet', 'description' => 'Café, pain, beurre, confiture, œuf, jus', 'prix' => 2500],
            ['categorie' => 'Petits Déjeuners', 'nom' => 'Petit Déjeuner Continental', 'description' => 'Viennoiseries, café, jus d\'orange', 'prix' => 3000],
            ['categorie' => 'Petits Déjeuners', 'nom' => 'Œufs au Plat', 'description' => 'Œufs au plat avec frites ou pain', 'prix' => 1800],
            ['categorie' => 'Petits Déjeuners', 'nom' => 'Œufs Brouillés', 'description' => 'Œufs brouillés avec jambon', 'prix' => 2000],
            ['categorie' => 'Petits Déjeuners', 'nom' => 'Croissant', 'description' => 'Croissant au beurre', 'prix' => 800],
            ['categorie' => 'Petits Déjeuners', 'nom' => 'Pain au Chocolat', 'description' => 'Chocolatine', 'prix' => 800],
            ['categorie' => 'Petits Déjeuners', 'nom' => 'Beignets', 'description' => 'Beignets sucrés (x3)', 'prix' => 1000],
            ['categorie' => 'Petits Déjeuners', 'nom' => 'Fruit de Saison', 'description' => 'Assortiment de fruits frais', 'prix' => 1500],
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
            } else {
                $this->command->warn("Catégorie non trouvée: " . $produitData['categorie']);
            }
        }

        $this->command->info('✓ ' . count($produits) . ' produits créés');
    }
}
