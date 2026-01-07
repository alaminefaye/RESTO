<?php

namespace Database\Seeders;

use App\Models\Table;
use App\Services\QRCodeService;
use Illuminate\Database\Seeder;

class TableSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $qrCodeService = new QRCodeService();

        $tables = [
            // Tables simples (10 tables)
            [
                'numero' => 'T1',
                'type' => Table::TYPE_SIMPLE,
                'capacite' => 4,
                'statut' => Table::STATUT_LIBRE,
                'actif' => true,
            ],
            [
                'numero' => 'T2',
                'type' => Table::TYPE_SIMPLE,
                'capacite' => 4,
                'statut' => Table::STATUT_LIBRE,
                'actif' => true,
            ],
            [
                'numero' => 'T3',
                'type' => Table::TYPE_SIMPLE,
                'capacite' => 2,
                'statut' => Table::STATUT_OCCUPEE,
                'actif' => true,
            ],
            [
                'numero' => 'T4',
                'type' => Table::TYPE_SIMPLE,
                'capacite' => 6,
                'statut' => Table::STATUT_LIBRE,
                'actif' => true,
            ],
            [
                'numero' => 'T5',
                'type' => Table::TYPE_SIMPLE,
                'capacite' => 4,
                'statut' => Table::STATUT_LIBRE,
                'actif' => true,
            ],
            [
                'numero' => 'T6',
                'type' => Table::TYPE_SIMPLE,
                'capacite' => 2,
                'statut' => Table::STATUT_RESERVEE,
                'actif' => true,
            ],
            [
                'numero' => 'T7',
                'type' => Table::TYPE_SIMPLE,
                'capacite' => 8,
                'statut' => Table::STATUT_LIBRE,
                'actif' => true,
            ],
            [
                'numero' => 'T8',
                'type' => Table::TYPE_SIMPLE,
                'capacite' => 4,
                'statut' => Table::STATUT_LIBRE,
                'actif' => true,
            ],
            [
                'numero' => 'T9',
                'type' => Table::TYPE_SIMPLE,
                'capacite' => 4,
                'statut' => Table::STATUT_LIBRE,
                'actif' => true,
            ],
            [
                'numero' => 'T10',
                'type' => Table::TYPE_SIMPLE,
                'capacite' => 6,
                'statut' => Table::STATUT_LIBRE,
                'actif' => true,
            ],

            // Tables VIP (3 tables)
            [
                'numero' => 'VIP1',
                'type' => Table::TYPE_VIP,
                'capacite' => 4,
                'statut' => Table::STATUT_LIBRE,
                'prix' => 50000, // 50 000 FCFA
                'actif' => true,
            ],
            [
                'numero' => 'VIP2',
                'type' => Table::TYPE_VIP,
                'capacite' => 6,
                'statut' => Table::STATUT_LIBRE,
                'prix' => 75000, // 75 000 FCFA
                'actif' => true,
            ],
            [
                'numero' => 'VIP3',
                'type' => Table::TYPE_VIP,
                'capacite' => 8,
                'statut' => Table::STATUT_OCCUPEE,
                'prix' => 100000, // 100 000 FCFA
                'actif' => true,
            ],

            // Espaces Jeux (2 espaces)
            [
                'numero' => 'JEU1',
                'type' => Table::TYPE_ESPACE_JEUX,
                'capacite' => 10,
                'statut' => Table::STATUT_LIBRE,
                'prix_par_heure' => 5000, // 5 000 FCFA/heure
                'actif' => true,
            ],
            [
                'numero' => 'JEU2',
                'type' => Table::TYPE_ESPACE_JEUX,
                'capacite' => 15,
                'statut' => Table::STATUT_RESERVEE,
                'prix_par_heure' => 7500, // 7 500 FCFA/heure
                'actif' => true,
            ],
        ];

        foreach ($tables as $tableData) {
            // Créer la table
            $table = Table::firstOrCreate(
                ['numero' => $tableData['numero']],
                $tableData
            );

            // Générer le QR Code si pas déjà généré
            if (!$table->qr_code) {
                $qrCodePath = $qrCodeService->generateForTable($table);
                $table->update(['qr_code' => $qrCodePath]);
                
                $this->command->info("✓ QR Code généré pour la table {$table->numero}");
            }
        }

        $this->command->info("✓ " . count($tables) . " tables créées avec succès!");
        $this->command->info("  - 10 tables simples");
        $this->command->info("  - 3 tables VIP");
        $this->command->info("  - 2 espaces jeux");
    }
}
