# 📝 VUES À CRÉER - Code Complet

## ✅ DÉJÀ FAIT
- Routes Web ✅
- TableController ✅
- 4 Vues Tables ✅
- MenuController ✅

## 🚧 À CRÉER MAINTENANT

### 1. Menu Categories (3 vues)

#### `resources/views/menu/categories/index.blade.php`
```blade
@extends('layouts.app')
@section('title', 'Catégories de Menu')
@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between">
        <h5 class="mb-0">📑 Catégories</h5>
        <a href="{{ route('menu.categories.create') }}" class="btn btn-primary">
            <i class="bx bx-plus"></i> Nouvelle Catégorie
        </a>
    </div>
    <div class="card-body">
        <table class="table">
            <thead>
                <tr>
                    <th>Nom</th>
                    <th>Produits</th>
                    <th>Ordre</th>
                    <th>Statut</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach($categories as $category)
                <tr>
                    <td><strong>{{ $category->name }}</strong></td>
                    <td><span class="badge bg-info">{{ $category->products_count }}</span></td>
                    <td>{{ $category->order }}</td>
                    <td>
                        @if($category->is_active)
                            <span class="badge bg-success">Actif</span>
                        @else
                            <span class="badge bg-secondary">Inactif</span>
                        @endif
                    </td>
                    <td>
                        <a href="{{ route('menu.categories.edit', $category) }}" class="btn btn-sm btn-warning">
                            <i class="bx bx-edit"></i>
                        </a>
                        <form action="{{ route('menu.categories.destroy', $category) }}" method="POST" style="display:inline;" onsubmit="return confirm('Supprimer ?')">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-sm btn-danger">
                                <i class="bx bx-trash"></i>
                            </button>
                        </form>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
@endsection
```

#### `resources/views/menu/categories/create.blade.php`
```blade
@extends('layouts.app')
@section('title', 'Nouvelle Catégorie')
@section('content')
<div class="card">
    <div class="card-header"><h5>➕ Nouvelle Catégorie</h5></div>
    <div class="card-body">
        <form action="{{ route('menu.categories.store') }}" method="POST">
            @csrf
            <div class="mb-3">
                <label class="form-label">Nom *</label>
                <input type="text" name="name" class="form-control @error('name') is-invalid @enderror" value="{{ old('name') }}" required>
                @error('name')<div class="invalid-feedback">{{ $message }}</div>@enderror
            </div>
            <div class="mb-3">
                <label class="form-label">Description</label>
                <textarea name="description" class="form-control" rows="3">{{ old('description') }}</textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">Ordre</label>
                <input type="number" name="order" class="form-control" value="{{ old('order', 0) }}">
            </div>
            <div class="mb-3">
                <div class="form-check">
                    <input type="checkbox" name="is_active" class="form-check-input" id="is_active" {{ old('is_active', true) ? 'checked' : '' }}>
                    <label class="form-check-label" for="is_active">Active</label>
                </div>
            </div>
            <div class="d-flex justify-content-between">
                <a href="{{ route('menu.categories.index') }}" class="btn btn-secondary">Retour</a>
                <button type="submit" class="btn btn-primary">Créer</button>
            </div>
        </form>
    </div>
</div>
@endsection
```

#### `resources/views/menu/categories/edit.blade.php`
```blade
@extends('layouts.app')
@section('title', 'Modifier Catégorie')
@section('content')
<div class="card">
    <div class="card-header"><h5>✏️ Modifier {{ $category->name }}</h5></div>
    <div class="card-body">
        <form action="{{ route('menu.categories.update', $category) }}" method="POST">
            @csrf
            @method('PUT')
            <div class="mb-3">
                <label class="form-label">Nom *</label>
                <input type="text" name="name" class="form-control @error('name') is-invalid @enderror" value="{{ old('name', $category->name) }}" required>
                @error('name')<div class="invalid-feedback">{{ $message }}</div>@enderror
            </div>
            <div class="mb-3">
                <label class="form-label">Description</label>
                <textarea name="description" class="form-control" rows="3">{{ old('description', $category->description) }}</textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">Ordre</label>
                <input type="number" name="order" class="form-control" value="{{ old('order', $category->order) }}">
            </div>
            <div class="mb-3">
                <div class="form-check">
                    <input type="checkbox" name="is_active" class="form-check-input" id="is_active" {{ old('is_active', $category->is_active) ? 'checked' : '' }}>
                    <label class="form-check-label" for="is_active">Active</label>
                </div>
            </div>
            <div class="d-flex justify-content-between">
                <a href="{{ route('menu.categories.index') }}" class="btn btn-secondary">Retour</a>
                <button type="submit" class="btn btn-primary">Enregistrer</button>
            </div>
        </form>
    </div>
</div>
@endsection
```

### 2. Menu Products (3 vues)

#### `resources/views/menu/products/index.blade.php`
```blade
@extends('layouts.app')
@section('title', 'Produits du Menu')
@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between">
        <h5 class="mb-0">🍽️ Produits</h5>
        <a href="{{ route('menu.products.create') }}" class="btn btn-primary">
            <i class="bx bx-plus"></i> Nouveau Produit
        </a>
    </div>
    <div class="card-body">
        <table class="table">
            <thead>
                <tr>
                    <th>Image</th>
                    <th>Nom</th>
                    <th>Catégorie</th>
                    <th>Prix</th>
                    <th>Disponible</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @foreach($products as $product)
                <tr>
                    <td>
                        @if($product->image_url)
                            <img src="{{ $product->image_url }}" alt="{{ $product->name }}" width="50" class="rounded">
                        @else
                            <span class="badge bg-secondary">Pas d'image</span>
                        @endif
                    </td>
                    <td><strong>{{ $product->name }}</strong></td>
                    <td><span class="badge bg-info">{{ $product->category->name }}</span></td>
                    <td>{{ number_format($product->price, 0, ',', ' ') }} FCFA</td>
                    <td>
                        <form action="{{ route('menu.products.toggle', $product) }}" method="POST" style="display:inline;">
                            @csrf
                            @if($product->is_available)
                                <button type="submit" class="btn btn-sm btn-success">✓ Dispo</button>
                            @else
                                <button type="submit" class="btn btn-sm btn-danger">✗ Rupture</button>
                            @endif
                        </form>
                    </td>
                    <td>
                        <a href="{{ route('menu.products.edit', $product) }}" class="btn btn-sm btn-warning">
                            <i class="bx bx-edit"></i>
                        </a>
                        <form action="{{ route('menu.products.destroy', $product) }}" method="POST" style="display:inline;" onsubmit="return confirm('Supprimer ?')">
                            @csrf
                            @method('DELETE')
                            <button type="submit" class="btn btn-sm btn-danger">
                                <i class="bx bx-trash"></i>
                            </button>
                        </form>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
@endsection
```

#### `resources/views/menu/products/create.blade.php` & `edit.blade.php`

**CREATE ET EDIT sont similaires** - Créer les fichiers avec les formulaires standards (nom, description, catégorie, prix, image, is_available, is_active).

---

## 🎯 ORDRE DE CRÉATION

1. Copier les 3 vues catégories ci-dessus
2. Copier la vue products/index.blade.php
3. Créer products/create.blade.php et products/edit.blade.php (similaires aux catégories)
4. Passer à CommandeController et ses vues
5. Passer à PaiementController et vues Caisse

**Temps estimé** : 30-45 minutes pour toutes les vues Menu

---

**Je continue à créer les fichiers maintenant ! 🚀**

