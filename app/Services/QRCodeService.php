<?php

namespace App\Services;

use App\Models\Table;
use Illuminate\Support\Facades\Storage;
use SimpleSoftwareIO\QrCode\Facades\QrCode;

class QRCodeService
{
    /**
     * Générer un QR Code pour une table
     * 
     * @param Table $table
     * @return string Chemin du fichier QR Code
     */
    public function generateForTable(Table $table): string
    {
        // URL qui sera encodée dans le QR Code
        // Format: {app_url}/api/table/{id}/menu
        $url = config('app.url') . '/api/tables/' . $table->id . '/menu';

        // Nom du fichier
        $filename = 'qr-codes/table-' . $table->numero . '-' . $table->id . '.svg';

        // Générer le QR Code en SVG
        $qrCode = QrCode::format('svg')
            ->size(300)
            ->margin(1)
            ->errorCorrection('H')
            ->generate($url);

        // Sauvegarder dans storage/app/public
        Storage::disk('public')->put($filename, $qrCode);

        return $filename;
    }

    /**
     * Générer un QR Code PNG au lieu de SVG
     * 
     * @param Table $table
     * @return string Chemin du fichier QR Code
     */
    public function generatePngForTable(Table $table): string
    {
        $url = config('app.url') . '/api/tables/' . $table->id . '/menu';
        $filename = 'qr-codes/table-' . $table->numero . '-' . $table->id . '.png';

        $qrCode = QrCode::format('png')
            ->size(300)
            ->margin(1)
            ->errorCorrection('H')
            ->generate($url);

        Storage::disk('public')->put($filename, $qrCode);

        return $filename;
    }

    /**
     * Supprimer le QR Code d'une table
     * 
     * @param Table $table
     * @return bool
     */
    public function deleteForTable(Table $table): bool
    {
        if (!$table->qr_code) {
            return true;
        }

        return Storage::disk('public')->delete($table->qr_code);
    }

    /**
     * Régénérer le QR Code d'une table
     * 
     * @param Table $table
     * @return string Chemin du nouveau fichier QR Code
     */
    public function regenerateForTable(Table $table): string
    {
        // Supprimer l'ancien QR Code
        $this->deleteForTable($table);

        // Générer un nouveau
        return $this->generateForTable($table);
    }

    /**
     * Générer les QR Codes pour toutes les tables
     * 
     * @return int Nombre de QR Codes générés
     */
    public function generateForAllTables(): int
    {
        $tables = Table::all();
        $count = 0;

        foreach ($tables as $table) {
            $qrCodePath = $this->generateForTable($table);
            $table->update(['qr_code' => $qrCodePath]);
            $count++;
        }

        return $count;
    }

    /**
     * Obtenir le contenu du QR Code pour affichage direct
     * 
     * @param Table $table
     * @return string Contenu SVG du QR Code
     */
    public function getQRCodeContent(Table $table): string
    {
        $url = config('app.url') . '/api/tables/' . $table->id . '/menu';

        return QrCode::format('svg')
            ->size(300)
            ->margin(1)
            ->errorCorrection('H')
            ->generate($url);
    }

    /**
     * Vérifier si un QR Code existe pour une table
     * 
     * @param Table $table
     * @return bool
     */
    public function exists(Table $table): bool
    {
        if (!$table->qr_code) {
            return false;
        }

        return Storage::disk('public')->exists($table->qr_code);
    }
}

