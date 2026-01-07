<?php

namespace Database\Seeders;

use App\Models\Table;
use App\Enums\TableType;
use App\Enums\TableStatus;
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
            // Tables simples (15 tables)
            [
                'numero' => 'T1',
                'type' => TableType::Simple->value,
                'capacite' => 2,
                'statut' => TableStatus::Libre->value,
                'actif' => true,
            ],
            [
                'numero' => 'T2',
                'type' => TableType::Simple->value,
                'capacite' => 2,
                'statut' => TableStatus::Libre->value,
                'actif' => true,
            ],
            [
                'numero' => 'T3',
                'type' => TableType::Simple->value,
                'capacite' => 4,
                'statut' => TableStatus::Occupee->value,
                'actif' => true,
            ],
            [
                'numero' => 'T4',
                'type' => TableType::Simple->value,
                'capacite' => 4,
                'statut' => TableStatus::Libre->value,
                'actif' => true,
            ],
            [
                'numero' => 'T5',
                'type' => TableType::Simple->value,
                'capacite' => 4,
                'statut' => TableStatus::Libre->value,
                'actif' => true,
            ],
            [
                'numero' => 'T6',
                'type' => TableType::Simple->value,
                'capacite' => 4,
                'statut' => TableStatus::Reservee->value,
                'actif' => true,
            ],
            [
                'numero' => 'T7',
                'type' => TableType::Simple->value,
                'capacite' => 6,
                'statut' => TableStatus::Libre->value,
                'actif' => true,
            ],
            [
                'numero' => 'T8',
                'type' => TableType::Simple->value,
                'capacite' => 6,
                'statut' => TableStatus::Libre->value,
                'actif' => true,
            ],
            [
                'numero' => 'T9',
                'type' => TableType::Simple->value,
                'capacite' => 6,
                'statut' => TableStatus::Libre->value,
                'actif' => true,
            ],
            [
                'numero' => 'T10',
                'type' => TableType::Simple->value,
                'capacite' => 8,
                'statut' => TableStatus::Libre->value,
                'actif' => true,
            ],
            [
                'numero' => 'T11',
                'type' => TableType::Simple->value,
                'capacite' => 8,
                'statut' => TableStatus::Libre->value,
                'actif' => true,
            ],
            [
                'numero' => 'T12',
                'type' => TableType::Simple->value,
                'capacite' => 4,
                'statut' => TableStatus::Libre->value,
                'actif' => true,
            ],
            [
                'numero' => 'T13',
                'type' => TableType::Simple->value,
                'capacite' => 4,
                'statut' => TableStatus::Libre->value,
                'actif' => true,
            ],
            [
                'numero' => 'T14',
                'type' => TableType::Simple->value,
                'capacite' => 2,
                'statut' => TableStatus::Libre->value,
                'actif' => true,
            ],
            [
                'numero' => 'T15',
                'type' => TableType::Simple->value,
                'capacite' => 10,
                'statut' => TableStatus::EnPaiement->value,
                'actif' => true,
            ],

            // Tables VIP (5 tables)
            [
                'numero' => 'VIP1',
                'type' => TableType::VIP->value,
                'capacite' => 4,
                'statut' => TableStatus::Libre->value,
                'prix' => 50000, // 50 000 FCFA
                'actif' => true,
            ],
            [
                'numero' => 'VIP2',
                'type' => TableType::VIP->value,
                'capacite' => 6,
                'statut' => TableStatus::Libre->value,
                'prix' => 75000, // 75 000 FCFA
                'actif' => true,
            ],
            [
                'numero' => 'VIP3',
                'type' => TableType::VIP->value,
                'capacite' => 8,
                'statut' => TableStatus::Occupee->value,
                'prix' => 100000, // 100 000 FCFA
                'actif' => true,
            ],
            [
                'numero' => 'VIP4',
                'type' => TableType::VIP->value,
                'capacite' => 10,
                'statut' => TableStatus::Reservee->value,
                'prix' => 125000, // 125 000 FCFA
                'actif' => true,
            ],
            [
                'numero' => 'VIP5',
                'type' => TableType::VIP->value,
                'capacite' => 12,
                'statut' => TableStatus::Libre->value,
                'prix' => 150000, // 150 000 FCFA
                'actif' => true,
            ],

            // Espaces Jeux (3 espaces)
            [
                'numero' => 'JEU1',
                'type' => TableType::EspaceJeux->value,
                'capacite' => 10,
                'statut' => TableStatus::Libre->value,
                'prix_par_heure' => 5000, // 5 000 FCFA/heure
                'actif' => true,
            ],
            [
                'numero' => 'JEU2',
                'type' => TableType::EspaceJeux->value,
                'capacite' => 15,
                'statut' => TableStatus::Reservee->value,
                'prix_par_heure' => 7500, // 7 500 FCFA/heure
                'actif' => true,
            ],
            [
                'numero' => 'JEU3',
                'type' => TableType::EspaceJeux->value,
                'capacite' => 20,
                'statut' => TableStatus::Occupee->value,
                'prix_par_heure' => 10000, // 10 000 FCFA/heure
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
                try {
                    $qrCodePath = $qrCodeService->generateForTable($table);
                    $table->update(['qr_code' => $qrCodePath]);
                    $this->command->info("✓ QR Code généré pour la table {$table->numero}");
                } catch (\Exception $e) {
                    $this->command->warn("⚠ Impossible de générer le QR Code pour {$table->numero}: " . $e->getMessage());
                }
            }
        }

        $this->command->info("✓ " . count($tables) . " tables créées avec succès!");
        $this->command->info("  - 15 tables simples");
        $this->command->info("  - 5 tables VIP");
        $this->command->info("  - 3 espaces jeux");
    }
}
