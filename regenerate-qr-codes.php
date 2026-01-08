<?php

/**
 * Script pour régénérer tous les QR codes avec la nouvelle URL
 * 
 * Usage: php regenerate-qr-codes.php
 */

require __DIR__ . '/vendor/autoload.php';

$app = require_once __DIR__ . '/bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

use App\Services\QRCodeService;
use App\Models\Table;

echo "🔄 Régénération des QR codes avec la nouvelle URL...\n\n";

$qrService = new QRCodeService();
$tables = Table::all();

if ($tables->isEmpty()) {
    echo "❌ Aucune table trouvée.\n";
    exit(1);
}

echo "📊 Nombre de tables à traiter: {$tables->count()}\n";
echo "🌐 URL utilisée: " . config('app.url') . "\n\n";

$count = 0;
foreach ($tables as $table) {
    try {
        $oldQrCode = $table->qr_code;
        $newQrCodePath = $qrService->regenerateForTable($table);
        $table->update(['qr_code' => $newQrCodePath]);
        
        $count++;
        echo "✅ Table {$table->numero} (ID: {$table->id}) - QR Code régénéré\n";
        
        if ($oldQrCode && $oldQrCode != $newQrCodePath) {
            echo "   Ancien: $oldQrCode\n";
            echo "   Nouveau: $newQrCodePath\n";
        }
    } catch (\Exception $e) {
        echo "❌ Erreur pour la table {$table->numero}: {$e->getMessage()}\n";
    }
}

echo "\n";
echo "✅ {$count} QR code(s) régénéré(s) avec succès !\n";
echo "🌐 Tous les QR codes utilisent maintenant: " . config('app.url') . "\n";

