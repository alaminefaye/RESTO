# 🎨 INTERFACE WEB - Guide de développement complet

## ✅ CE QUI EST FAIT

### 1. Structure de base
- ✅ Template Sneat installé (Bootstrap)
- ✅ Layout principal (`layouts/app.blade.php`)
- ✅ Menu latéral complet créé
- ✅ Controllers Web créés :
  - `Web/TableController`
  - `Web/MenuController`
  - `Web/CommandeController`
  - `Web/PaiementController`

### 2. API Backend
- ✅ 43 endpoints API fonctionnels
- ✅ Tous les models et relations
- ✅ Services (QRCode, Facture)

---

## 🎯 CE QU'IL RESTE À FAIRE

### ÉTAPE 1 : Vérifier Dashboard Controller

```bash
# Vérifier si le fichier existe
ls -la app/Http/Controllers/DashboardController.php
```

### ÉTAPE 2 : Créer les Routes Web

Éditer `routes/web.php` et ajouter :

```php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\Web\TableController;
use App\Http\Controllers\Web\MenuController;
use App\Http\Controllers\Web\CommandeController;
use App\Http\Controllers\Web\PaiementController;

// Authentication Routes
Route::get('/login', [LoginController::class, 'showLoginForm'])->name('login');
Route::post('/login', [LoginController::class, 'login']);
Route::post('/logout', [LoginController::class, 'logout'])->name('logout');

// Protected Routes
Route::middleware(['auth'])->group(function () {
    // Dashboard
    Route::get('/', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/dashboard', [DashboardController::class, 'index']);
    
    // Tables
    Route::resource('tables', TableController::class);
    Route::post('tables/{table}/regenerate-qr', [TableController::class, 'regenerateQr'])
        ->name('tables.regenerate-qr');
    
    // Menu - Categories
    Route::prefix('menu')->name('menu.')->group(function () {
        Route::resource('categories', MenuController::class, [
            'names' => [
                'index' => 'categories.index',
                'create' => 'categories.create',
                'store' => 'categories.store',
                'show' => 'categories.show',
                'edit' => 'categories.edit',
                'update' => 'categories.update',
                'destroy' => 'categories.destroy'
            ]
        ]);
        
        // Products
        Route::get('products', [MenuController::class, 'productsIndex'])->name('products.index');
        Route::get('products/create', [MenuController::class, 'productsCreate'])->name('products.create');
        Route::post('products', [MenuController::class, 'productsStore'])->name('products.store');
        Route::get('products/{product}/edit', [MenuController::class, 'productsEdit'])->name('products.edit');
        Route::put('products/{product}', [MenuController::class, 'productsUpdate'])->name('products.update');
        Route::delete('products/{product}', [MenuController::class, 'productsDestroy'])->name('products.destroy');
        Route::post('products/{product}/toggle', [MenuController::class, 'toggleAvailability'])->name('products.toggle');
    });
    
    // Commandes
    Route::resource('commandes', CommandeController::class);
    Route::post('commandes/{commande}/add-product', [CommandeController::class, 'addProduct'])
        ->name('commandes.add-product');
    Route::delete('commandes/{commande}/remove-product/{product}', [CommandeController::class, 'removeProduct'])
        ->name('commandes.remove-product');
    Route::patch('commandes/{commande}/status', [CommandeController::class, 'updateStatus'])
        ->name('commandes.update-status');
    
    // Caisse
    Route::get('caisse', [PaiementController::class, 'caisse'])->name('caisse.index');
    Route::post('caisse/{commande}/payer', [PaiementController::class, 'processPayment'])
        ->name('caisse.payer');
    
    // Paiements
    Route::get('paiements', [PaiementController::class, 'index'])->name('paiements.index');
    Route::get('paiements/{paiement}', [PaiementController::class, 'show'])->name('paiements.show');
    Route::get('paiements/{paiement}/facture', [PaiementController::class, 'downloadFacture'])
        ->name('paiements.facture');
});
```

### ÉTAPE 3 : Vues à créer

#### A) Dashboard (`resources/views/dashboard.blade.php`)

Déjà existant, à améliorer avec des statistiques en temps réel depuis l'API.

#### B) Tables (`resources/views/tables/`)

**Créer les fichiers** :
- `index.blade.php` - Liste des tables avec filtres (libre/occupée)
- `create.blade.php` - Formulaire création table
- `edit.blade.php` - Formulaire édition table
- `show.blade.php` - Détails d'une table + QR Code

#### C) Menu (`resources/views/menu/`)

**Créer les dossiers et fichiers** :
- `categories/index.blade.php` - Liste catégories
- `categories/create.blade.php` - Créer catégorie
- `categories/edit.blade.php` - Éditer catégorie
- `products/index.blade.php` - Liste produits avec images
- `products/create.blade.php` - Créer produit + upload image
- `products/edit.blade.php` - Éditer produit

#### D) Commandes (`resources/views/commandes/`)

**Créer les fichiers** :
- `index.blade.php` - Liste toutes commandes avec filtres
- `create.blade.php` - Nouvelle commande (sélection table + produits)
- `show.blade.php` - Détails commande + bouton paiement
- `edit.blade.php` - Modifier commande (ajouter/retirer produits)

#### E) Caisse (`resources/views/caisse/`)

**Créer les fichiers** :
- `index.blade.php` - Interface caisse avec commandes en attente de paiement
- `payment.blade.php` - Modal/page de paiement (espèces/Wave/Orange)

#### F) Paiements (`resources/views/paiements/`)

**Créer les fichiers** :
- `index.blade.php` - Historique des paiements
- `show.blade.php` - Détails paiement + facture

---

## 💡 APPROCHE RAPIDE (MVP)

### Ordre de priorité :

1. **Dashboard** (améliorer l'existant)
   - Statistiques : tables occupées, commandes du jour, CA du jour
   - Widgets visuels

2. **Tables** (CRITIQUE)
   - Index : Afficher toutes les tables avec statuts visuels
   - Bouton changement statut direct
   - Affichage QR Code

3. **Menu** (IMPORTANT)
   - Categories Index + Create
   - Products Index + Create
   - Upload d'images fonctionnel

4. **Commandes** (CRITIQUE)
   - Index : Liste avec filtre par statut
   - Create : Interface rapide prise de commande
   - Show : Détails + actions (modifier, payer)

5. **Caisse** (ESSENTIEL)
   - Interface simple : liste commandes à payer
   - Bouton "Encaisser" avec modal choix moyen
   - Génération facture automatique

---

## 🎨 DESIGN PATTERN À SUIVRE

### Layout Sneat déjà présent

```blade
@extends('layouts.app')

@section('title', 'Nom de la page')

@section('content')
    <div class="row">
        <div class="col-12">
            <div class="card">
                <h5 class="card-header">Titre</h5>
                <div class="card-body">
                    <!-- Contenu -->
                </div>
            </div>
        </div>
    </div>
@endsection
```

### Boutons standards Sneat

```html
<!-- Primary -->
<button type="button" class="btn btn-primary">Primaire</button>

<!-- Success -->
<button type="button" class="btn btn-success">Succès</button>

<!-- Danger -->
<button type="button" class="btn btn-danger">Danger</button>

<!-- Warning -->
<button type="button" class="btn btn-warning">Attention</button>

<!-- Info -->
<button type="button" class="btn btn-info">Info</button>
```

### Badges pour statuts

```html
<!-- Table libre -->
<span class="badge bg-success">Libre</span>

<!-- Table occupée -->
<span class="badge bg-danger">Occupée</span>

<!-- Commande en attente -->
<span class="badge bg-warning">En attente</span>

<!-- Commande servie -->
<span class="badge bg-info">Servie</span>

<!-- Commande terminée -->
<span class="badge bg-success">Terminée</span>
```

---

## 🛠️ CONTROLLERS - Méthodes à implémenter

### DashboardController

```php
public function index()
{
    // Récupérer stats depuis l'API ou directement des models
    $stats = [
        'tables_occupees' => Table::where('statut', 'occupee')->count(),
        'tables_total' => Table::count(),
        'commandes_jour' => Commande::whereDate('created_at', today())->count(),
        'ca_jour' => Paiement::whereDate('created_at', today())
                            ->where('statut', 'valide')
                            ->sum('montant'),
    ];
    
    return view('dashboard', compact('stats'));
}
```

### TableController (Web)

```php
public function index()
{
    $tables = Table::all();
    return view('tables.index', compact('tables'));
}

public function create()
{
    return view('tables.create');
}

public function store(Request $request)
{
    // Validation + Appel API interne
    // OU Utiliser directement les models
}

// ... autres méthodes CRUD
```

### MenuController (Web)

Gérer à la fois categories et products avec des méthodes séparées.

### CommandeController (Web)

```php
public function index()
{
    $commandes = Commande::with(['table', 'products'])->latest()->paginate(20);
    return view('commandes.index', compact('commandes'));
}

public function create()
{
    $tables = Table::where('statut', 'libre')->get();
    $categories = Category::with('products')->get();
    return view('commandes.create', compact('tables', 'categories'));
}

// ... store, show, edit, update, etc.
```

### PaiementController (Web)

```php
public function caisse()
{
    $commandes = Commande::whereIn('statut', ['servie', 'en_attente'])
                        ->with('table')
                        ->get();
    return view('caisse.index', compact('commandes'));
}

public function processPayment(Request $request, Commande $commande)
{
    // Appeler le PaiementController de l'API
    // OU Utiliser directement le service
    
    // Retourner avec succès + télécharger facture
}
```

---

## 📦 UTILISER L'API INTERNE

### Option 1 : Appel HTTP interne

```php
use Illuminate\Support\Facades\Http;

$response = Http::withToken(auth()->user()->createToken('internal')->plainTextToken)
                ->get(route('api.tables.index'));

$tables = $response->json();
```

### Option 2 : Utiliser directement les Models (RECOMMANDÉ)

```php
use App\Models\Table;

$tables = Table::all();
```

**RECOMMANDATION** : Utiliser directement les Models pour le web, c'est plus simple et rapide.

---

## 🎯 PROCHAINE ÉTAPE IMMÉDIATE

### 1. Créer le DashboardController

```bash
php artisan make:controller DashboardController
```

### 2. Améliorer la vue Dashboard

Ajouter des widgets avec statistiques temps réel.

### 3. Créer les vues Tables

Commencer par `tables/index.blade.php` qui affiche toutes les tables.

### 4. Tester chaque fonctionnalité

Au fur et à mesure, tester dans le navigateur.

---

## 💡 TEMPLATE VUE EXEMPLE

### `resources/views/tables/index.blade.php`

```blade
@extends('layouts.app')

@section('title', 'Gestion des Tables')

@section('content')
<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">Liste des Tables</h5>
                <a href="{{ route('tables.create') }}" class="btn btn-primary">
                    <i class="bx bx-plus"></i> Nouvelle Table
                </a>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-bordered">
                        <thead>
                            <tr>
                                <th>Numéro</th>
                                <th>Type</th>
                                <th>Capacité</th>
                                <th>Statut</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($tables as $table)
                                <tr>
                                    <td><strong>{{ $table->numero }}</strong></td>
                                    <td>
                                        <span class="badge bg-secondary">{{ ucfirst($table->type->value) }}</span>
                                    </td>
                                    <td>{{ $table->capacite }} pers.</td>
                                    <td>
                                        @switch($table->statut->value)
                                            @case('libre')
                                                <span class="badge bg-success">Libre</span>
                                                @break
                                            @case('occupee')
                                                <span class="badge bg-danger">Occupée</span>
                                                @break
                                            @case('reservee')
                                                <span class="badge bg-warning">Réservée</span>
                                                @break
                                            @case('en_paiement')
                                                <span class="badge bg-info">En paiement</span>
                                                @break
                                        @endswitch
                                    </td>
                                    <td>
                                        <a href="{{ route('tables.show', $table) }}" class="btn btn-sm btn-info">
                                            <i class="bx bx-show"></i>
                                        </a>
                                        <a href="{{ route('tables.edit', $table) }}" class="btn btn-sm btn-warning">
                                            <i class="bx bx-edit"></i>
                                        </a>
                                        <form action="{{ route('tables.destroy', $table) }}" method="POST" style="display:inline;">
                                            @csrf
                                            @method('DELETE')
                                            <button type="submit" class="btn btn-sm btn-danger" onclick="return confirm('Supprimer cette table ?')">
                                                <i class="bx bx-trash"></i>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="5" class="text-center">Aucune table trouvée</td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection
```

---

## 🚀 POUR COMPILER LES ASSETS

Si besoin de recompiler Tailwind (mais Sneat utilise Bootstrap) :

```bash
npm install
npm run dev
```

Pour Sneat, normalement pas besoin car les assets sont déjà compilés dans `public/assets/`.

---

## ✅ CHECKLIST DÉVELOPPEMENT

### Controllers
- [x] DashboardController existe
- [x] TableController créé
- [x] MenuController créé
- [x] CommandeController créé
- [x] PaiementController créé

### Routes
- [ ] Routes web ajoutées dans `routes/web.php`

### Vues
- [ ] Dashboard amélioré
- [ ] Tables (index, create, edit, show)
- [ ] Menu categories (index, create, edit)
- [ ] Menu products (index, create, edit)
- [ ] Commandes (index, create, show)
- [ ] Caisse (index)
- [ ] Paiements (index, show)

### Tests
- [ ] Login fonctionnel
- [ ] Dashboard affiche stats
- [ ] Création table fonctionne
- [ ] Liste produits s'affiche
- [ ] Prise de commande fonctionne
- [ ] Paiement génère facture

---

## 💡 ASTUCE DÉVELOPPEMENT RAPIDE

### 1. Commencer par les vues Index

Créer d'abord toutes les vues `index.blade.php` pour avoir une vue d'ensemble.

### 2. Puis les controllers avec juste index()

Faire fonctionner l'affichage des listes avant de faire le CRUD complet.

### 3. Puis Create/Store

Ajouter la création ensuite.

### 4. Enfin Edit/Update/Delete

Terminer par les modifications et suppressions.

---

**GUIDE COMPLET POUR TERMINER L'INTERFACE WEB ! 🎨**

Suivez ce guide étape par étape pour avoir un système web complet et fonctionnel !

