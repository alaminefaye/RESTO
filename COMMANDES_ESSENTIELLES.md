# ⚡ COMMANDES ESSENTIELLES - Démarrage Rapide

## 🚀 Démarrer le projet

```bash
# 1. Aller dans le dossier
cd /Users/Zhuanz/Desktop/projets/web/resto

# 2. Démarrer le serveur
php artisan serve

# 3. Dans un autre terminal - Lancer les workers (optionnel)
php artisan queue:work
```

**Accès** : http://localhost:8000

---

## 🔑 Connexion rapide

### Via curl
```bash
# Obtenir un token
TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@admin.com","password":"password"}' \
  | jq -r '.access_token')

echo $TOKEN
```

### Comptes disponibles
- **Admin** : `admin@admin.com` / `password`
- **Manager** : `manager@resto.com` / `password`
- **Caissier** : `caissier@resto.com` / `password`
- **Serveur** : `serveur@resto.com` / `password`

---

## 💳 Test paiement complet

```bash
# 1. Se connecter
TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"caissier@resto.com","password":"password"}' \
  | jq -r '.access_token')

# 2. Créer une commande
COMMANDE=$(curl -s -X POST http://localhost:8000/api/commandes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "table_id": 1,
    "produits": [
      {"produit_id": 1, "quantite": 2},
      {"produit_id": 5, "quantite": 1}
    ]
  }' | jq -r '.id')

echo "Commande créée: $COMMANDE"

# 3. Payer en espèces
curl -X POST "http://localhost:8000/api/paiements/especes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"commande_id\": $COMMANDE,
    \"montant_recu\": 20000
  }" | jq

# 4. Vérifier que la table est libre
curl -s http://localhost:8000/api/tables/1 \
  -H "Authorization: Bearer $TOKEN" | jq '.statut'
```

---

## 📊 Commandes utiles

### Base de données
```bash
# Réinitialiser la base (ATTENTION: efface tout !)
php artisan migrate:fresh --seed

# Lancer seulement les nouvelles migrations
php artisan migrate

# Voir le statut des migrations
php artisan migrate:status

# Lancer un seeder spécifique
php artisan db:seed --class=TableSeeder
```

### Cache
```bash
# Vider tous les caches
php artisan optimize:clear

# OU spécifiquement
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear
```

### Debugging
```bash
# Voir les routes
php artisan route:list

# Voir les logs en temps réel
tail -f storage/logs/laravel.log

# Tester la connexion DB
php artisan tinker
> DB::connection()->getPdo();
```

---

## 🔍 Vérifications rapides

### API disponible ?
```bash
curl http://localhost:8000/api/auth/login
# Devrait retourner erreur 422 (validation)
```

### Tables créées ?
```bash
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/tables | jq length
# Devrait retourner: 15
```

### Produits disponibles ?
```bash
curl -H "Authorization: Bearer $TOKEN" \
  http://localhost:8000/api/produits | jq length
# Devrait retourner: 21
```

---

## 📁 Fichiers importants

### Configuration
- `.env` - Variables d'environnement
- `config/database.php` - Config DB
- `config/auth.php` - Config auth

### Routes
- `routes/api.php` - Toutes les routes API

### Controllers
- `app/Http/Controllers/Api/`

### Models
- `app/Models/`

### Services
- `app/Services/QRCodeService.php`
- `app/Services/FactureService.php`

---

## 🐛 Résolution problèmes courants

### Erreur "Class not found"
```bash
composer dump-autoload
```

### Erreur permissions storage
```bash
chmod -R 775 storage bootstrap/cache
```

### Liens symboliques manquants
```bash
php artisan storage:link
```

### Migrations en erreur
```bash
php artisan migrate:fresh --seed
# Recommence tout depuis zéro
```

---

## 📱 Pour l'app mobile

### Base URL
```
http://localhost:8000/api
```

### Headers requis
```
Content-Type: application/json
Authorization: Bearer {token}
```

### Workflow login
```
1. POST /api/auth/login
   → Récupérer le token
   
2. Utiliser le token dans toutes les requêtes:
   Headers: { Authorization: "Bearer {token}" }
```

---

## 🎯 Tests rapides essentiels

### 1. Authentification
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@admin.com","password":"password"}'
```

### 2. Liste des tables
```bash
curl http://localhost:8000/api/tables \
  -H "Authorization: Bearer $TOKEN"
```

### 3. Menu complet
```bash
curl http://localhost:8000/api/categories \
  -H "Authorization: Bearer $TOKEN"
```

### 4. Paiement espèces
```bash
curl -X POST http://localhost:8000/api/paiements/especes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"commande_id":1,"montant_recu":10000}'
```

---

## ⚙️ Configuration production

### Avant déploiement
```bash
# 1. Optimiser
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 2. Générer key
php artisan key:generate

# 3. Lancer migrations
php artisan migrate --force

# 4. Peupler données
php artisan db:seed

# 5. Lien storage
php artisan storage:link
```

### Variables .env importantes
```env
APP_ENV=production
APP_DEBUG=false
APP_URL=https://votre-domaine.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_DATABASE=resto_prod
DB_USERNAME=root
DB_PASSWORD=votre_password

SANCTUM_STATEFUL_DOMAINS=votre-domaine.com
SESSION_DOMAIN=.votre-domaine.com
```

---

## 📞 Aide rapide

### Besoin de réinitialiser ?
```bash
php artisan migrate:fresh --seed
```

### Besoin de voir les erreurs ?
```bash
tail -f storage/logs/laravel.log
```

### Besoin de tester l'API ?
- Voir `TEST_API.md`
- Voir `TEST_TABLES_API.md`
- Voir `TEST_PAIEMENTS_API.md`

---

**Gardez ce fichier sous la main ! 📌**

