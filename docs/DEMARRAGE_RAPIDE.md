# 🚀 Démarrage Rapide - Restaurant Management System

## ⚡ Lancer l'application

### 1. Démarrer le serveur Laravel
```bash
cd /Users/Zhuanz/Desktop/projets/web/resto
php artisan serve
```

L'application sera accessible sur : **http://localhost:8000**

---

## 🧪 Tester l'API

### Méthode 1 : CURL (Terminal)

#### Login
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "admin@admin.com",
    "password": "password"
  }'
```

**Copier le token reçu**, puis :

#### Obtenir les infos utilisateur
```bash
curl -X GET http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer VOTRE_TOKEN_ICI" \
  -H "Accept: application/json"
```

### Méthode 2 : Postman / Insomnia

1. **Créer une requête POST** : `http://localhost:8000/api/auth/login`
2. **Body (JSON)** :
   ```json
   {
     "email": "admin@admin.com",
     "password": "password"
   }
   ```
3. **Copier le token** de la réponse
4. **Créer une requête GET** : `http://localhost:8000/api/auth/me`
5. **Header** : `Authorization: Bearer {token}`

---

## 👥 Comptes de test

| Rôle | Email | Mot de passe | Permissions |
|------|-------|-------------|-------------|
| **Admin** | admin@admin.com | password | Toutes (37) |
| **Manager** | manager@resto.com | password | Toutes sauf settings (35) |
| **Caissier** | caissier@resto.com | password | Caisse et paiements (9) |
| **Serveur** | serveur@resto.com | password | Commandes et tables (8) |

---

## 📚 Commandes utiles

### Voir les routes
```bash
# Toutes les routes
php artisan route:list

# Routes API uniquement
php artisan route:list --path=api
```

### Base de données
```bash
# Rafraîchir la BDD et les données de test
php artisan migrate:fresh --seed

# Lancer uniquement les seeders
php artisan db:seed

# Entrer en mode console Laravel
php artisan tinker
```

### Vérifier un utilisateur en console
```bash
php artisan tinker
```
```php
// Récupérer l'admin
$admin = User::where('email', 'admin@admin.com')->first();

// Voir ses rôles
$admin->roles;

// Voir ses permissions
$admin->getAllPermissions();

// Vérifier un rôle
$admin->hasRole('admin'); // true

// Vérifier une permission
$admin->hasPermission('manage_users'); // true
```

---

## 🗂️ Structure du projet

```
resto/
├── app/
│   ├── Models/
│   │   ├── User.php ✅ (avec rôles & permissions)
│   │   ├── Role.php ✅
│   │   └── Permission.php ✅
│   ├── Http/
│   │   ├── Controllers/
│   │   │   └── Api/
│   │   │       └── AuthController.php ✅
│   │   └── Middleware/
│   │       ├── CheckRole.php ✅
│   │       └── CheckPermission.php ✅
│
├── database/
│   ├── migrations/ ✅ (roles, permissions, pivots)
│   └── seeders/ ✅ (37 permissions, 4 rôles, 4 users)
│
├── routes/
│   ├── api.php ✅ (auth endpoints)
│   └── web.php
│
├── README.md ✅ (Documentation complète)
├── ETAPE_1_COMPLETE.md ✅
├── TEST_API.md ✅
└── DEMARRAGE_RAPIDE.md ✅ (ce fichier)
```

---

## 🔐 Endpoints API disponibles

### Publics (pas de token)
- `POST /api/auth/login` - Connexion

### Protégés (token requis)
- `GET /api/auth/me` - Infos utilisateur
- `POST /api/auth/logout` - Déconnexion
- `POST /api/auth/logout-all` - Déconnexion tous appareils
- `POST /api/auth/refresh` - Rafraîchir token

---

## 📱 Prêt pour le Mobile

L'API est maintenant prête pour être consommée par l'application mobile Flutter :

1. ✅ **Authentification** avec tokens Sanctum
2. ✅ **Rôles et permissions** configurés
3. ✅ **Réponses JSON** standardisées
4. ✅ **Sécurité** en place
5. ✅ **Documentation** disponible

---

## 🎯 Prochaines étapes

### ÉTAPE 2 : Tables & QR Code
- Créer la gestion des tables
- Générer des QR Codes
- Interface CRUD
- Système de statuts

**Prêt à continuer ?** Lancez simplement :
```bash
php artisan serve
```

Et commencez à développer ! 🚀

