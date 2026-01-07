# ✅ ÉTAPE 2 - TABLES & QR CODE - TERMINÉE

## 🎉 Résumé

L'**ÉTAPE 2 - Tables & QR Code** a été complétée avec succès ! Votre système de gestion des tables avec génération automatique de QR Codes est maintenant opérationnel.

---

## 📦 Ce qui a été installé

### Packages
- ✅ **SimpleSoftwareIO/simple-qrcode** (v4.2.0) - Génération de QR Codes
- ✅ **bacon/bacon-qr-code** (v2.0.8) - Dépendance pour QR Codes
- ✅ **dasprid/enum** (v1.0.7) - Support des enums

---

## 🗄️ Base de Données

### Table créée : `tables`

**Champs** :
- `id` - Identifiant unique
- `numero` - Numéro de la table (unique, ex: T1, VIP1, JEU1)
- `type` - Type de table (simple, vip, espace_jeux)
- `capacite` - Nombre de places
- `statut` - Statut actuel (libre, occupee, reservee, paiement)
- `prix` - Prix pour tables VIP (nullable)
- `prix_par_heure` - Prix par heure pour espaces jeux (nullable)
- `qr_code` - Chemin vers le fichier QR Code
- `actif` - Table active ou non
- `timestamps` - Dates de création et modification

**Index** :
- Index sur `type` pour filtrage rapide
- Index sur `statut` pour recherche par statut
- Index sur `actif` pour tables actives

---

## 📊 Données de Test

### 15 Tables créées

#### 10 Tables Simples
- **T1 à T10** - Capacités variables (2 à 8 places)
- Statuts variés (libre, occupée, réservée)
- QR Codes générés pour chacune

#### 3 Tables VIP
- **VIP1** - 4 places - 50 000 FCFA
- **VIP2** - 6 places - 75 000 FCFA
- **VIP3** - 8 places - 100 000 FCFA (occupée)

#### 2 Espaces Jeux
- **JEU1** - 10 places - 5 000 FCFA/heure
- **JEU2** - 15 places - 7 500 FCFA/heure (réservé)

**Tous les QR Codes ont été générés automatiquement !** ✅

---

## 🎯 Modèle Table Créé

**Fichier**: `app/Models/Table.php`

### Constantes
```php
// Types
TYPE_SIMPLE = 'simple'
TYPE_VIP = 'vip'
TYPE_ESPACE_JEUX = 'espace_jeux'

// Statuts
STATUT_LIBRE = 'libre'
STATUT_OCCUPEE = 'occupee'
STATUT_RESERVEE = 'reservee'
STATUT_PAIEMENT = 'paiement'
```

### Méthodes principales
- `isLibre()` - Vérifier si libre
- `isOccupee()` - Vérifier si occupée
- `isReservee()` - Vérifier si réservée
- `changerStatut()` - Changer le statut
- `liberer()` - Libérer la table
- `occuper()` - Marquer comme occupée
- `reserver()` - Marquer comme réservée

### Scopes (filtres)
- `ofType($type)` - Par type
- `ofStatut($statut)` - Par statut
- `libres()` - Tables libres seulement
- `actives()` - Tables actives seulement

### Accesseurs
- `type_display` - Nom affiché du type
- `statut_display` - Nom affiché du statut
- `qr_code_url` - URL complète du QR Code

---

## 🔧 Service QRCodeService Créé

**Fichier**: `app/Services/QRCodeService.php`

### Méthodes disponibles

#### Génération
- `generateForTable($table)` - Générer QR Code SVG
- `generatePngForTable($table)` - Générer QR Code PNG
- `generateForAllTables()` - Générer pour toutes les tables

#### Gestion
- `deleteForTable($table)` - Supprimer le QR Code
- `regenerateForTable($table)` - Régénérer le QR Code
- `getQRCodeContent($table)` - Obtenir le contenu SVG
- `exists($table)` - Vérifier l'existence

### Format du QR Code
- **Format**: SVG (ou PNG si besoin)
- **Taille**: 300x300 pixels
- **Correction d'erreur**: Niveau H (haute)
- **URL encodée**: `{app_url}/api/tables/{id}/menu`

---

## 🌐 API REST - Endpoints Tables

### Routes Publiques (authentification requise)

#### 📋 Liste des tables
```
GET /api/tables
```
**Filtres optionnels** :
- `?type=simple` - Filtrer par type
- `?statut=libre` - Filtrer par statut
- `?actif=true` - Filtrer actives/inactives

**Réponse** :
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "numero": "T1",
      "type": "simple",
      "type_display": "Table Simple",
      "capacite": 4,
      "statut": "libre",
      "statut_display": "Libre",
      "prix": null,
      "prix_par_heure": null,
      "qr_code": "qr-codes/table-T1-1.svg",
      "qr_code_url": "http://localhost:8000/storage/qr-codes/table-T1-1.svg",
      "actif": true,
      "created_at": "...",
      "updated_at": "..."
    }
  ]
}
```

#### 🆓 Tables libres
```
GET /api/tables/libres
```

#### 🔍 Détails d'une table
```
GET /api/tables/{id}
```

#### 📱 QR Code d'une table
```
GET /api/tables/{id}/qrcode
```
**Retourne** : Image SVG directement

---

### Routes Protégées

#### 🔄 Changer le statut
```
PATCH /api/tables/{id}/statut
```
**Permission requise** : `update_table_status`

**Body** :
```json
{
  "statut": "occupee"
}
```

#### ➕ Créer une table
```
POST /api/tables
```
**Permission requise** : `manage_tables`

**Body** :
```json
{
  "numero": "T11",
  "type": "simple",
  "capacite": 4,
  "actif": true
}
```

#### ✏️ Modifier une table
```
PUT/PATCH /api/tables/{id}
```
**Permission requise** : `manage_tables`

**Body** :
```json
{
  "numero": "T11-NEW",
  "capacite": 6,
  "statut": "libre"
}
```

#### 🗑️ Supprimer une table
```
DELETE /api/tables/{id}
```
**Permission requise** : `manage_tables`

#### 🔁 Régénérer QR Code
```
POST /api/tables/{id}/regenerate-qrcode
```
**Permission requise** : `manage_tables`

---

## 📝 Fichiers Créés

### Backend
```
app/
├── Models/
│   └── Table.php ✅
├── Services/
│   └── QRCodeService.php ✅
└── Http/
    └── Controllers/
        └── Api/
            └── TableController.php ✅

database/
├── migrations/
│   └── 2026_01_06_192513_create_tables_table.php ✅
└── seeders/
    └── TableSeeder.php ✅

routes/
└── api.php ✅ (routes tables ajoutées)

storage/
└── app/
    └── public/
        └── qr-codes/ ✅ (15 QR Codes générés)
```

---

## 🧪 Tests de l'API

### 1. Lister toutes les tables
```bash
curl -X GET http://localhost:8000/api/tables \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### 2. Tables libres seulement
```bash
curl -X GET http://localhost:8000/api/tables/libres \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### 3. Obtenir une table spécifique
```bash
curl -X GET http://localhost:8000/api/tables/1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### 4. Voir le QR Code
```bash
# Dans le navigateur
http://localhost:8000/api/tables/1/qrcode

# Ou avec curl
curl -X GET http://localhost:8000/api/tables/1/qrcode \
  -H "Authorization: Bearer YOUR_TOKEN" \
  > qrcode.svg
```

### 5. Changer le statut (serveur/caissier)
```bash
curl -X PATCH http://localhost:8000/api/tables/1/statut \
  -H "Authorization: Bearer SERVEUR_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"statut": "occupee"}'
```

### 6. Créer une nouvelle table (admin/manager)
```bash
curl -X POST http://localhost:8000/api/tables \
  -H "Authorization: Bearer ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "numero": "T11",
    "type": "simple",
    "capacite": 4
  }'
```

---

## 🔐 Permissions

### Qui peut faire quoi ?

| Action | Serveur | Caissier | Manager | Admin |
|--------|---------|----------|---------|-------|
| Voir les tables | ✅ | ✅ | ✅ | ✅ |
| Voir tables libres | ✅ | ✅ | ✅ | ✅ |
| Changer statut | ✅ | ❌ | ✅ | ✅ |
| Créer table | ❌ | ❌ | ✅ | ✅ |
| Modifier table | ❌ | ❌ | ✅ | ✅ |
| Supprimer table | ❌ | ❌ | ✅ | ✅ |
| Régénérer QR | ❌ | ❌ | ✅ | ✅ |

---

## 📱 Intégration Mobile

### Workflow Client Mobile

1. **Client scanne le QR Code** de la table
2. **QR Code contient** : `http://localhost:8000/api/tables/{id}/menu`
3. **App mobile lit l'URL** et extrait l'ID de la table
4. **App fait un GET** sur `/api/tables/{id}` pour vérifier :
   - Table est libre ou occupée ?
   - Type de table
   - Capacité
5. **App affiche le menu** correspondant
6. **Client passe sa commande** via l'app

### URL du QR Code
Chaque QR Code encode une URL comme :
```
http://localhost:8000/api/tables/1/menu
```

En production, remplacer par votre domaine :
```
https://votre-resto.com/api/tables/1/menu
```

---

## ✅ Checklist

- [x] Migration tables créée
- [x] Package QR Code installé
- [x] Modèle Table avec méthodes utiles
- [x] Service QRCodeService
- [x] TableController API avec toutes les méthodes
- [x] Routes API configurées avec permissions
- [x] Seeder avec 15 tables de test
- [x] 15 QR Codes générés automatiquement
- [x] Lien symbolique storage créé
- [x] Tests manuels effectués

---

## 🎯 Prochaines étapes - ÉTAPE 3

### ÉTAPE 3 - Menu & Commandes

Nous allons créer :

#### 3.1 Gestion du Menu
- Migration categories
- Migration produits
- Modèles Category et Product
- Controllers pour l'API
- Upload d'images
- CRUD complet

#### 3.2 Gestion des Commandes
- Migration commandes
- Migration commande_produits (pivot)
- Modèle Commande
- CommandeController
- Système temps réel
- Calcul automatique du total
- Notifications cuisine

**Prêt à continuer avec l'ÉTAPE 3 ?** 🚀

---

## 📞 Commandes utiles

### Voir les tables en BDD
```bash
php artisan tinker
```
```php
Table::all();
Table::libres()->get();
Table::where('type', 'vip')->get();
```

### Régénérer tous les QR Codes
```bash
php artisan tinker
```
```php
$service = new \App\Services\QRCodeService();
$service->generateForAllTables();
```

### Réinitialiser les tables
```bash
php artisan migrate:fresh --seed
php artisan db:seed --class=TableSeeder
```

---

**Félicitations ! L'ÉTAPE 2 est terminée !** 🎊

Vous avez maintenant un système complet de gestion des tables avec QR Codes prêt pour votre restaurant !

