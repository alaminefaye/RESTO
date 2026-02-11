# 💳 TESTS API - PAIEMENTS & FACTURES (ÉTAPE 5)

## 📋 Prérequis

```bash
# S'assurer que le serveur est lancé
php artisan serve

# Obtenir un token d'authentification
TOKEN="votre_token_ici"
```

---

## 🔐 1. SE CONNECTER

```bash
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "caissier@resto.com",
    "password": "password"
  }'
```

**Réponse attendue** : Token + infos utilisateur

---

## 📊 2. VÉRIFIER LES COMMANDES EXISTANTES

```bash
curl -X GET "http://localhost:8000/api/commandes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

**Objectif** : Trouver une commande à payer

---

## 💵 3. WORKFLOW PAIEMENT ESPÈCES (Recommandé - Plus simple)

### Option A : Workflow complet en une seule requête 🎯

```bash
curl -X POST "http://localhost:8000/api/paiements/especes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "commande_id": 1,
    "montant_recu": 10000,
    "notes": "Client satisfait"
  }'
```

**Ce que ça fait automatiquement** :
- ✅ Crée le paiement
- ✅ Calcule la monnaie rendue
- ✅ Valide le paiement
- ✅ Génère la facture PDF
- ✅ Termine la commande
- ✅ Libère la table

**Réponse attendue** :
```json
{
  "message": "Paiement espèces effectué avec succès",
  "paiement": {
    "id": 1,
    "commande_id": 1,
    "montant": 7500,
    "moyen_paiement": "especes",
    "statut": "valide",
    "montant_recu": 10000,
    "monnaie_rendue": 2500,
    "facture": {
      "numero_facture": "FAC-20260106-0001",
      "pdf_url": "/storage/factures/facture-FAC-20260106-0001.pdf"
    }
  },
  "facture": { ... },
  "monnaie_rendue": 2500
}
```

---

## 📱 4. WORKFLOW PAIEMENT MOBILE MONEY (Wave / Orange Money)

### Étape 1 : Initier le paiement

```bash
curl -X POST "http://localhost:8000/api/paiements" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "commande_id": 2,
    "moyen_paiement": "wave",
    "transaction_id": "WAVE123456789",
    "notes": "Paiement via Wave"
  }'
```

**Réponse attendue** : Paiement créé avec statut "en_attente"

### Étape 2 : Valider le paiement (après confirmation client)

```bash
curl -X PATCH "http://localhost:8000/api/paiements/1/valider" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

**Ce que ça fait** :
- ✅ Valide le paiement
- ✅ Génère la facture PDF
- ✅ Termine la commande
- ✅ Libère la table

---

## 💳 5. PAIEMENT CARTE BANCAIRE

```bash
curl -X POST "http://localhost:8000/api/paiements/especes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "commande_id": 3,
    "montant_recu": 8000,
    "notes": "Paiement par carte"
  }'
```

---

## 📥 6. TÉLÉCHARGER UNE FACTURE

```bash
curl -X GET "http://localhost:8000/api/paiements/1/facture" \
  -H "Authorization: Bearer $TOKEN" \
  --output facture.pdf
```

**Résultat** : Fichier PDF téléchargé

---

## 📊 7. VOIR TOUS LES PAIEMENTS

```bash
curl -X GET "http://localhost:8000/api/paiements" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

---

## 🔍 8. DÉTAILS D'UN PAIEMENT

```bash
curl -X GET "http://localhost:8000/api/paiements/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

---

## ❌ 9. MARQUER UN PAIEMENT COMME ÉCHOUÉ

```bash
curl -X PATCH "http://localhost:8000/api/paiements/1/echouer" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

**Ce que ça fait** :
- ❌ Marque le paiement comme échoué
- 🪑 Remet la table en statut "occupée"

---

## 🗑️ 10. ANNULER UN PAIEMENT

```bash
curl -X DELETE "http://localhost:8000/api/paiements/1" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json"
```

---

## 🎯 SCÉNARIO COMPLET DE TEST

### Préparation

```bash
# 1. Se connecter
TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"caissier@resto.com","password":"password"}' \
  | jq -r '.access_token')

echo "Token: $TOKEN"
```

### Scénario 1 : Client paie en espèces

```bash
# 1. Créer une commande
COMMANDE=$(curl -s -X POST http://localhost:8000/api/commandes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "table_id": 1,
    "produits": [
      {"produit_id": 1, "quantite": 2},
      {"produit_id": 2, "quantite": 1}
    ]
  }' | jq -r '.id')

echo "Commande créée: $COMMANDE"

# 2. Payer en espèces (workflow complet)
curl -X POST "http://localhost:8000/api/paiements/especes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"commande_id\": $COMMANDE,
    \"montant_recu\": 10000,
    \"notes\": \"Test paiement espèces\"
  }" | jq

# 3. Vérifier que la table est libre
curl -s http://localhost:8000/api/tables/1 \
  -H "Authorization: Bearer $TOKEN" | jq '.statut'
```

### Scénario 2 : Client paie via Wave

```bash
# 1. Créer une commande
COMMANDE2=$(curl -s -X POST http://localhost:8000/api/commandes \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "table_id": 2,
    "produits": [
      {"produit_id": 5, "quantite": 1}
    ]
  }' | jq -r '.id')

# 2. Initier le paiement Wave
PAIEMENT=$(curl -s -X POST http://localhost:8000/api/paiements \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"commande_id\": $COMMANDE2,
    \"moyen_paiement\": \"wave\",
    \"transaction_id\": \"WAVE$(date +%s)\"
  }" | jq -r '.paiement.id')

echo "Paiement initié: $PAIEMENT"

# 3. Attendre confirmation client...
echo "En attente de confirmation Wave..."

# 4. Valider le paiement
curl -X PATCH "http://localhost:8000/api/paiements/$PAIEMENT/valider" \
  -H "Authorization: Bearer $TOKEN" | jq

# 5. Télécharger la facture
curl -X GET "http://localhost:8000/api/paiements/$PAIEMENT/facture" \
  -H "Authorization: Bearer $TOKEN" \
  --output "facture-$PAIEMENT.pdf"

echo "Facture téléchargée: facture-$PAIEMENT.pdf"
```

---

## 📋 VÉRIFICATIONS IMPORTANTES

### 1. Vérifier qu'on ne peut pas payer deux fois

```bash
# Essayer de payer à nouveau la même commande
curl -X POST "http://localhost:8000/api/paiements/especes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "commande_id": 1,
    "montant_recu": 10000
  }'
```

**Réponse attendue** : Erreur 409 "Cette commande a déjà été payée."

### 2. Vérifier le montant insuffisant

```bash
curl -X POST "http://localhost:8000/api/paiements/especes" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "commande_id": 2,
    "montant_recu": 1000
  }'
```

**Réponse attendue** : Erreur 422 "Le montant reçu est insuffisant."

### 3. Vérifier la génération du PDF

```bash
# Lister les factures générées
ls -lah storage/app/public/factures/
```

---

## 🎉 RÉSULTAT ATTENDU

Après un paiement réussi :

1. ✅ **Paiement créé** avec statut "valide"
2. ✅ **Facture générée** avec numéro unique (FAC-YYYYMMDD-XXXX)
3. ✅ **PDF créé** dans `storage/app/public/factures/`
4. ✅ **Commande terminée** (statut = "completed")
5. ✅ **Table libérée** (statut = "libre")
6. ✅ **Monnaie calculée** (pour espèces)

---

## 🐛 DÉBOGAGE

### Si le PDF ne se génère pas

```bash
# Vérifier les permissions
chmod -R 775 storage/
chmod -R 775 bootstrap/cache/

# Créer le dossier factures
mkdir -p storage/app/public/factures
chmod 775 storage/app/public/factures

# Créer le lien symbolique
php artisan storage:link
```

### Voir les logs Laravel

```bash
tail -f storage/logs/laravel.log
```

---

## 📊 PERMISSIONS REQUISES

- **view_cashier** : Voir les paiements
- **process_payments** : Créer/valider des paiements
- **generate_invoices** : Télécharger les factures

**Utilisateurs autorisés** : Caissier, Manager, Admin

---

## 🚀 WORKFLOW DE PRODUCTION

### Pour un restaurant réel

1. **Client termine son repas**
2. **Serveur/Caissier** :
   - Sélectionne la table
   - Vérifie le montant total
   - Demande le moyen de paiement

3. **Si ESPÈCES** :
   ```
   POST /api/paiements/especes
   → Termine immédiatement
   → Imprime la facture
   ```

4. **Si MOBILE MONEY** :
   ```
   POST /api/paiements (initier)
   → Client paie sur son téléphone
   → Caissier reçoit notification
   PATCH /api/paiements/{id}/valider
   → Termine et imprime facture
   ```

5. **Table libérée automatiquement** ✅
6. **Points fidélité attribués** (si activé)
7. **Statistiques mises à jour** automatiquement

---

## 💡 CONSEILS

- Toujours tester avec `montant_recu` > `montant_total` pour espèces
- Vérifier la connexion réseau pour mobile money
- Garder les factures PDF pour la comptabilité
- Sauvegarder régulièrement les paiements

---

## ✅ CHECKLIST AVANT OUVERTURE

- [ ] Migrations exécutées
- [ ] DomPDF installé
- [ ] Template facture créé
- [ ] Permissions storage correctes
- [ ] Lien symbolique créé (`storage:link`)
- [ ] Tests paiements espèces OK
- [ ] Tests paiements mobile money OK
- [ ] Génération PDF OK
- [ ] Libération table automatique OK

---

**Votre système de paiement est prêt ! 💳✨**

