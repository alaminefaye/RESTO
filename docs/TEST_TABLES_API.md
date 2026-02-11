# 🧪 Tests API - Tables

## 🔑 Obtenir un Token

D'abord, connectez-vous pour obtenir un token :

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"email":"admin@admin.com","password":"password"}'
```

**Copiez le token** de la réponse et utilisez-le dans les commandes suivantes.

---

## 📋 1. Lister toutes les tables

```bash
curl -X GET "http://localhost:8000/api/tables" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

### Avec filtres

**Tables simples** :
```bash
curl -X GET "http://localhost:8000/api/tables?type=simple" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

**Tables VIP** :
```bash
curl -X GET "http://localhost:8000/api/tables?type=vip" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

**Tables libres** :
```bash
curl -X GET "http://localhost:8000/api/tables?statut=libre" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

## 🆓 2. Tables libres seulement

```bash
curl -X GET "http://localhost:8000/api/tables/libres" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

## 🔍 3. Détails d'une table

```bash
curl -X GET "http://localhost:8000/api/tables/1" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

## 📱 4. Voir le QR Code

### Dans le navigateur
Ouvrez : `http://localhost:8000/api/tables/1/qrcode`

### Télécharger avec curl
```bash
curl -X GET "http://localhost:8000/api/tables/1/qrcode" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -o qrcode.svg
```

---

## 🔄 5. Changer le statut d'une table

**Marquer comme occupée** :
```bash
curl -X PATCH "http://localhost:8000/api/tables/1/statut" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"statut":"occupee"}'
```

**Libérer la table** :
```bash
curl -X PATCH "http://localhost:8000/api/tables/1/statut" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"statut":"libre"}'
```

**Marquer comme réservée** :
```bash
curl -X PATCH "http://localhost:8000/api/tables/1/statut" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"statut":"reservee"}'
```

**En cours de paiement** :
```bash
curl -X PATCH "http://localhost:8000/api/tables/1/statut" \
  -H "Authorization: Bearer YOUR_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{"statut":"paiement"}'
```

---

## ➕ 6. Créer une nouvelle table

**Requiert permission** : `manage_tables` (Admin ou Manager)

```bash
curl -X POST "http://localhost:8000/api/tables" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "numero": "T11",
    "type": "simple",
    "capacite": 4
  }'
```

**Table VIP** :
```bash
curl -X POST "http://localhost:8000/api/tables" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "numero": "VIP4",
    "type": "vip",
    "capacite": 6,
    "prix": 80000
  }'
```

**Espace jeux** :
```bash
curl -X POST "http://localhost:8000/api/tables" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "numero": "JEU3",
    "type": "espace_jeux",
    "capacite": 12,
    "prix_par_heure": 6000
  }'
```

---

## ✏️ 7. Modifier une table

**Requiert permission** : `manage_tables`

```bash
curl -X PUT "http://localhost:8000/api/tables/1" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "capacite": 6,
    "actif": true
  }'
```

---

## 🔁 8. Régénérer le QR Code

**Requiert permission** : `manage_tables`

```bash
curl -X POST "http://localhost:8000/api/tables/1/regenerate-qrcode" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN_HERE" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json"
```

---

## 🗑️ 9. Supprimer une table

**Requiert permission** : `manage_tables`

```bash
curl -X DELETE "http://localhost:8000/api/tables/1" \
  -H "Authorization: Bearer YOUR_ADMIN_TOKEN_HERE" \
  -H "Accept: application/json"
```

---

## 📊 Exemple de réponse

### Succès
```json
{
  "success": true,
  "data": {
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
    "created_at": "2026-01-06T19:30:00.000000Z",
    "updated_at": "2026-01-06T19:30:00.000000Z"
  }
}
```

### Erreur (validation)
```json
{
  "success": false,
  "message": "Erreur de validation",
  "errors": {
    "numero": ["Le champ numero est obligatoire."],
    "type": ["Le type sélectionné est invalide."]
  }
}
```

### Erreur (non trouvé)
```json
{
  "success": false,
  "message": "Table non trouvée"
}
```

### Erreur (permission)
```json
{
  "message": "Accès refusé. Permission requise: manage_tables"
}
```

---

## 🔥 Postman Collection

Si vous utilisez Postman, importez cette collection :

### Variables
- `base_url` : `http://localhost:8000`
- `token` : `YOUR_TOKEN_HERE`

### Requêtes pré-configurées
1. Auth - Login
2. Tables - List All
3. Tables - Libres
4. Tables - Get One
5. Tables - Get QR Code
6. Tables - Update Status
7. Tables - Create
8. Tables - Update
9. Tables - Delete
10. Tables - Regenerate QR

---

## 💡 Tips

### Utiliser jq pour formatter JSON
```bash
curl ... | jq '.'
```

### Sauvegarder la réponse
```bash
curl ... > response.json
```

### Voir les headers de réponse
```bash
curl -i ...
```

### Mode verbose (debug)
```bash
curl -v ...
```

---

## 🎯 Tables de test disponibles

| Numéro | Type | Capacité | Statut | Prix |
|--------|------|----------|--------|------|
| T1-T10 | Simple | 2-8 | Variés | - |
| VIP1 | VIP | 4 | Libre | 50 000 |
| VIP2 | VIP | 6 | Libre | 75 000 |
| VIP3 | VIP | 8 | Occupée | 100 000 |
| JEU1 | Espace Jeux | 10 | Libre | 5 000/h |
| JEU2 | Espace Jeux | 15 | Réservé | 7 500/h |

---

## 🚀 Bon test !

N'oubliez pas de démarrer le serveur :
```bash
php artisan serve
```

