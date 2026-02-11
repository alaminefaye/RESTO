# 🔄 RÉGÉNÉRATION DES QR CODES

## ✅ Corrections Apportées

### Problème
Les QR codes contenaient `localhost` au lieu de l'URL de production (`http://restaurant.universaltechnologiesafrica.com`).

### Solution
- ✅ Le service `QRCodeService` utilise maintenant `env('APP_URL')` avec fallback vers l'URL de production
- ✅ L'application mobile peut maintenant extraire correctement l'ID de table depuis l'URL du QR code
- ✅ Support de différents formats d'URL (`/api/tables/{id}/menu`, `/tables/{id}`, etc.)

---

## 🔧 Configuration

### 1. Vérifier/Corriger `.env`

Assurez-vous que votre fichier `.env` contient :

```env
APP_URL=http://restaurant.universaltechnologiesafrica.com
```

**Important** : Pas de trailing slash (`/`) à la fin de l'URL !

### 2. Vérifier la Configuration

Vérifiez que `config('app.url')` retourne la bonne URL :

```bash
php artisan tinker
>>> config('app.url')
```

Si ce n'est pas la bonne URL, mettez à jour le `.env` et rechargez la configuration :

```bash
php artisan config:clear
php artisan config:cache
```

---

## 🔄 Régénérer les QR Codes

### Option 1 : Via l'Interface Web

1. Allez sur la page d'une table : `/tables/{id}`
2. Cliquez sur le bouton **Régénérer QR Code** (icône de rafraîchissement)
3. Répétez pour chaque table

### Option 2 : Via Tinker (Toutes les Tables)

```bash
php artisan tinker
```

```php
use App\Services\QRCodeService;
use App\Models\Table;

$qrService = new QRCodeService();

// Régénérer tous les QR codes
$tables = Table::all();
foreach ($tables as $table) {
    $qrService->regenerateForTable($table);
    echo "QR Code régénéré pour la table {$table->numero}\n";
}
```

### Option 3 : Créer une Commande Artisan (Recommandé)

Créez une commande Artisan pour régénérer tous les QR codes :

```bash
php artisan make:command RegenerateQRCodes
```

Puis dans `app/Console/Commands/RegenerateQRCodes.php` :

```php
<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use App\Services\QRCodeService;
use App\Models\Table;

class RegenerateQRCodes extends Command
{
    protected $signature = 'qr:regenerate {--table= : ID de la table spécifique}';
    protected $description = 'Régénérer tous les QR codes avec la nouvelle URL';

    public function handle(QRCodeService $qrService)
    {
        $tableId = $this->option('table');

        if ($tableId) {
            $table = Table::find($tableId);
            if (!$table) {
                $this->error("Table #{$tableId} non trouvée");
                return 1;
            }
            $qrService->regenerateForTable($table);
            $this->info("QR Code régénéré pour la table {$table->numero}");
        } else {
            $tables = Table::all();
            $this->info("Régénération des QR codes pour {$tables->count()} tables...");
            
            $bar = $this->output->createProgressBar($tables->count());
            $bar->start();

            foreach ($tables as $table) {
                $qrService->regenerateForTable($table);
                $bar->advance();
            }

            $bar->finish();
            $this->newLine();
            $this->info("✅ {$tables->count()} QR codes régénérés avec succès !");
        }

        return 0;
    }
}
```

Ensuite, exécutez :

```bash
# Régénérer toutes les tables
php artisan qr:regenerate

# Régénérer une table spécifique
php artisan qr:regenerate --table=1
```

---

## ✅ Vérification

### 1. Vérifier le Contenu d'un QR Code

Après régénération, scannez un QR code avec votre téléphone et vérifiez que l'URL est :

```
http://restaurant.universaltechnologiesafrica.com/api/tables/{id}/menu
```

**Pas** :
- ❌ `http://localhost:8000/api/tables/{id}/menu`
- ❌ `http://127.0.0.1/api/tables/{id}/menu`
- ❌ `http://resto.test/api/tables/{id}/menu`

### 2. Tester avec l'Application Mobile

1. Ouvrez l'application mobile Flutter
2. Allez dans l'onglet "Tables"
3. Cliquez sur "Scanner QR Code"
4. Scannez le QR code régénéré
5. Vérifiez que l'application récupère correctement la table

### 3. Vérifier via l'API

Testez l'endpoint directement dans votre navigateur :

```
http://restaurant.universaltechnologiesafrica.com/api/tables/{id}
```

Remplacez `{id}` par l'ID de la table.

---

## 📝 Notes Importantes

### Format de l'URL dans le QR Code

Le QR code contient maintenant :
```
http://restaurant.universaltechnologiesafrica.com/api/tables/{id}/menu
```

Où `{id}` est l'ID de la table (pas le numéro).

### Extraction par l'Application Mobile

L'application mobile Flutter extrait l'ID de table depuis l'URL du QR code en cherchant :
- `/tables/{id}` (avec 's')
- `/table/{id}` (sans 's', pour compatibilité)
- Ou directement l'ID si c'est juste un nombre

### Endpoint `/api/tables/{id}/menu`

Cet endpoint devrait rediriger vers le menu avec le `table_id` prérempli, ou retourner les informations nécessaires à l'application mobile.

**Note** : Si cet endpoint n'existe pas encore, vous devrez le créer dans `routes/api.php` :

```php
Route::get('/tables/{id}/menu', function ($id) {
    return response()->json([
        'table_id' => $id,
        'redirect' => '/menu?table_id=' . $id,
    ]);
});
```

---

## 🚀 Déploiement en Production

Lors du déploiement en production :

1. ✅ Vérifiez que `APP_URL` dans `.env` est correct
2. ✅ Régénérez tous les QR codes existants
3. ✅ Téléchargez et imprimez les nouveaux QR codes
4. ✅ Remplacez les anciens QR codes sur les tables
5. ✅ Testez avec l'application mobile

---

## 🐛 Dépannage

### Les QR codes contiennent encore localhost

**Cause** : Les anciens QR codes sont toujours enregistrés.

**Solution** : Régénérez tous les QR codes (voir section "Régénérer les QR Codes" ci-dessus).

### L'application mobile ne trouve pas la table

**Cause** : L'URL du QR code n'est pas dans le bon format.

**Solution** : 
1. Vérifiez le contenu du QR code scanné
2. Assurez-vous qu'il contient `/api/tables/{id}/menu`
3. Vérifiez que l'ID extrait est correct

### Erreur 404 lors du scan

**Cause** : L'endpoint `/api/tables/{id}/menu` n'existe pas.

**Solution** : Créez l'endpoint dans `routes/api.php` (voir section "Notes Importantes" ci-dessus).

---

## ✅ Checklist Finale

- [ ] `.env` contient `APP_URL=http://restaurant.universaltechnologiesafrica.com`
- [ ] Configuration Laravel rechargée (`php artisan config:clear && php artisan config:cache`)
- [ ] Tous les QR codes régénérés
- [ ] QR code testé et contient la bonne URL
- [ ] Application mobile teste le scan avec succès
- [ ] Endpoint `/api/tables/{id}/menu` existe et fonctionne

