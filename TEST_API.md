# 🧪 Tests API - Restaurant Management System

## 🔐 Authentification

### 1. Login (Connexion)

**Endpoint**: `POST /api/auth/login`

**Body**:
```json
{
  "email": "admin@admin.com",
  "password": "password"
}
```

**Réponse attendue**:
```json
{
  "message": "Connexion réussie",
  "user": {
    "id": 1,
    "name": "Admin User",
    "email": "admin@admin.com",
    "roles": ["admin"],
    "permissions": ["manage_users", "view_users", ...]
  },
  "token": "1|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "token_type": "Bearer"
}
```

### 2. Get Current User (Utilisateur connecté)

**Endpoint**: `GET /api/auth/me`

**Headers**:
```
Authorization: Bearer {token}
```

**Réponse attendue**:
```json
{
  "user": {
    "id": 1,
    "name": "Admin User",
    "email": "admin@admin.com",
    "email_verified_at": null,
    "created_at": "2026-01-06T19:18:15.000000Z",
    "roles": [
      {
        "id": 1,
        "name": "admin",
        "display_name": "Administrateur"
      }
    ],
    "permissions": [...]
  }
}
```

### 3. Refresh Token

**Endpoint**: `POST /api/auth/refresh`

**Headers**:
```
Authorization: Bearer {token}
```

**Réponse attendue**:
```json
{
  "message": "Token rafraîchi avec succès",
  "token": "2|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "token_type": "Bearer"
}
```

### 4. Logout (Déconnexion)

**Endpoint**: `POST /api/auth/logout`

**Headers**:
```
Authorization: Bearer {token}
```

**Réponse attendue**:
```json
{
  "message": "Déconnexion réussie"
}
```

### 5. Logout All (Déconnexion de tous les appareils)

**Endpoint**: `POST /api/auth/logout-all`

**Headers**:
```
Authorization: Bearer {token}
```

**Réponse attendue**:
```json
{
  "message": "Déconnexion de tous les appareils réussie"
}
```

---

## 👥 Utilisateurs de test

| Email | Mot de passe | Rôle | Permissions |
|-------|-------------|------|-------------|
| admin@admin.com | password | Admin | Toutes |
| manager@resto.com | password | Manager | Toutes sauf paramètres système |
| caissier@resto.com | password | Caissier | Caisse, paiements, vue commandes |
| serveur@resto.com | password | Serveur | Commandes, tables, vue menu |

---

## 🧪 Commandes CURL pour tester

### Login
```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "admin@admin.com",
    "password": "password"
  }'
```

### Get Current User
```bash
curl -X GET http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

### Logout
```bash
curl -X POST http://localhost:8000/api/auth/logout \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

## 📝 Notes

- Tous les endpoints API sont préfixés par `/api`
- Le token doit être inclus dans le header `Authorization: Bearer {token}`
- Les tokens sont générés avec les permissions de l'utilisateur (abilities)
- Utilisez Postman, Insomnia ou Thunder Client pour tester facilement

