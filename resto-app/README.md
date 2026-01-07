# 🍽️ Resto App - Application Mobile Flutter

Application mobile complète pour la gestion de restaurant, connectée à l'API Laravel.

## 📦 Structure du Projet

```
lib/
├── config/          # Configuration (API, etc.)
├── models/          # Modèles de données
├── screens/         # Écrans de l'application
│   ├── auth/       # Authentification
│   ├── menu/       # Menu (Catégories & Produits)
│   ├── tables/     # Tables & Scan QR
│   ├── orders/     # Commandes & Panier
│   └── profile/    # Profil utilisateur
├── services/        # Services API
├── widgets/         # Widgets réutilisables
└── utils/           # Utilitaires (formatters, etc.)
```

## ✅ Modules Implémentés

### 1. 🔐 Authentification
- **Login Screen** : Connexion avec email/mot de passe
- **AuthService** : Gestion de l'authentification avec Provider
- **Token Storage** : Sauvegarde automatique du token dans SharedPreferences
- **Auto-login** : Vérification automatique au démarrage

### 2. 🍽️ Menu
- **Categories Screen** : Liste des catégories avec navigation vers produits
- **Products Screen** : Liste des produits avec images
- **Recherche** : Recherche en temps réel par nom
- **Filtres** : Filtrage par catégorie
- **Navigation** : Navigation depuis catégories vers produits de la catégorie

### 3. 🪑 Tables
- **Tables Screen** : Liste des tables avec statuts visuels
- **Table Detail Screen** : Détails complets + QR Code
- **QR Scan Screen** : Scanner QR code pour accéder à une table
- **Navigation** : Navigation table → menu avec association automatique

### 4. 📝 Commandes
- **Panier (Cart)** : Gestion du panier avec Provider
- **Cart Screen** : Interface du panier avec modification des quantités
- **Orders Screen** : Historique des commandes
- **Order Detail Screen** : Détails complets d'une commande
- **Création** : Création de commande depuis le panier

### 5. 👤 Profil
- **Profile Screen** : Informations utilisateur
- **Rôles** : Affichage des rôles avec badges
- **Déconnexion** : Déconnexion avec confirmation

## 🎨 Fonctionnalités

### Navigation
- ✅ Navigation fluide entre tous les modules
- ✅ Navigation catégories → produits (filtrage automatique)
- ✅ Navigation table → menu (association automatique)
- ✅ Bouton retour sur les écrans de détails

### Recherche & Filtres
- ✅ Recherche de produits en temps réel
- ✅ Filtrage par catégorie avec chips
- ✅ Filtres combinables (recherche + catégorie)

### Panier
- ✅ Ajout de produits au panier
- ✅ Modification des quantités
- ✅ Suppression de produits
- ✅ Calcul automatique du total
- ✅ Badge avec nombre d'articles
- ✅ Association automatique avec la table

### UX/UI
- ✅ Formatage des montants (FCFA avec séparateurs)
- ✅ Formatage des dates (relative et absolue)
- ✅ Animations Hero pour les images
- ✅ Loading states
- ✅ Empty states avec messages
- ✅ Gestion d'erreurs complète
- ✅ Feedback visuel (SnackBars)

## 📱 Navigation Principale

L'application a **5 onglets** dans le menu principal :

1. **Tables** - Liste des tables, scan QR
2. **Catégories** - Liste des catégories
3. **Produits** - Liste des produits avec recherche/filtres
4. **Commandes** - Historique des commandes
5. **Profil** - Informations utilisateur

## 🔧 Configuration

### 1. Modifier l'URL de l'API

Éditez `lib/config/api_config.dart` :

```dart
static const String baseUrl = 'http://votre-serveur.com/api';
```

### 2. Installer les dépendances

```bash
cd resto-app
flutter pub get
```

### 3. Lancer l'application

```bash
flutter run
```

## 📦 Dépendances Principales

- **dio** : Client HTTP pour les appels API
- **provider** : State management
- **shared_preferences** : Stockage local (token)
- **cached_network_image** : Chargement d'images optimisé
- **mobile_scanner** : Scanner QR code
- **qr_flutter** : Génération de QR codes
- **intl** : Formatage des dates et montants

## 🔐 Authentification API

L'application utilise l'API Laravel Sanctum pour l'authentification.

**Endpoint de login** : `POST /api/auth/login`

**Body** :
```json
{
  "email": "user@example.com",
  "password": "password"
}
```

**Response** :
```json
{
  "token": "1|...",
  "user": {
    "id": 1,
    "name": "User Name",
    "email": "user@example.com",
    "roles": ["admin"]
  }
}
```

## 🚀 Flux Utilisateur Typique

1. **Login** → Connexion avec email/mot de passe
2. **Scan QR** ou **Sélection Table** → Accès au menu de la table
3. **Parcourir Catégories** → Navigation vers produits de la catégorie
4. **Rechercher Produits** → Recherche et filtrage
5. **Ajouter au Panier** → Ajout de produits avec quantités
6. **Passer Commande** → Création de la commande
7. **Suivre Commande** → Voir l'historique et les statuts

## 📋 Prochaines Améliorations Possibles

- [ ] Notifications push pour les mises à jour de commande
- [ ] Mode hors-ligne avec cache local
- [ ] Historique des commandes avec pagination
- [ ] Évaluation des produits/commandes
- [ ] Partage de commandes
- [ ] Mode sombre
- [ ] Multilingue (FR/EN)

## 🐛 Résolution de Problèmes

### L'application plante au démarrage
```bash
flutter clean
flutter pub get
flutter run
```

### Erreur de cache Gradle/Kotlin
```bash
./fix_build.sh
```

### Problème de permissions caméra
Vérifiez que les permissions sont bien configurées dans `android/app/src/main/AndroidManifest.xml`

## 📄 License

Ce projet est développé pour la gestion de restaurant.

---

**🎉 Application 100% fonctionnelle et prête pour la production !**
