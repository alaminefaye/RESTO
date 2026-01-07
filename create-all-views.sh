#!/bin/bash

# Script pour créer toutes les vues manquantes
# À exécuter depuis la racine du projet : bash create-all-views.sh

echo "🚀 Création de toutes les vues manquantes..."

# Créer les dossiers
mkdir -p resources/views/menu/categories
mkdir -p resources/views/menu/products  
mkdir -p resources/views/commandes
mkdir -p resources/views/caisse
mkdir -p resources/views/paiements

echo "✅ Dossiers créés"

# Menu Categories - Index
cat > resources/views/menu/categories/index.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Catégories')
@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between">
        <h5 class="mb-0">📑 Catégories</h5>
        <a href="{{ route('menu.categories.create') }}" class="btn btn-primary"><i class="bx bx-plus"></i> Nouvelle</a>
    </div>
    <div class="card-body">
        <table class="table">
            <thead><tr><th>Nom</th><th>Produits</th><th>Ordre</th><th>Statut</th><th>Actions</th></tr></thead>
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
                        <a href="{{ route('menu.categories.edit', $category) }}" class="btn btn-sm btn-warning"><i class="bx bx-edit"></i></a>
                        <form action="{{ route('menu.categories.destroy', $category) }}" method="POST" style="display:inline;" onsubmit="return confirm('Supprimer ?')">
                            @csrf @method('DELETE')
                            <button type="submit" class="btn btn-sm btn-danger"><i class="bx bx-trash"></i></button>
                        </form>
                    </td>
                </tr>
                @endforeach
            </tbody>
        </table>
    </div>
</div>
@endsection
EOF

echo "✅ menu/categories/index.blade.php créé"

# Menu Categories - Create (formulaire simple)
cat > resources/views/menu/categories/create.blade.php << 'EOF'
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
                    <input type="checkbox" name="is_active" class="form-check-input" id="is_active" checked>
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
EOF

echo "✅ menu/categories/create.blade.php créé"

# Menu Categories - Edit
cat > resources/views/menu/categories/edit.blade.php << 'EOF'
@extends('layouts.app')
@section('title', 'Modifier Catégorie')
@section('content')
<div class="card">
    <div class="card-header"><h5>✏️ Modifier {{ $category->name }}</h5></div>
    <div class="card-body">
        <form action="{{ route('menu.categories.update', $category) }}" method="POST">
            @csrf @method('PUT')
            <div class="mb-3">
                <label class="form-label">Nom *</label>
                <input type="text" name="name" class="form-control" value="{{ old('name', $category->name) }}" required>
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
EOF

echo "✅ menu/categories/edit.blade.php créé"

echo ""
echo "🎉 Script terminé !"
echo ""
echo "📝 Vues créées :"
echo "  - menu/categories/index.blade.php"
echo "  - menu/categories/create.blade.php"
echo "  - menu/categories/edit.blade.php"
echo ""
echo "⚠️  À créer manuellement (avec upload d'image) :"
echo "  - menu/products/create.blade.php"
echo "  - menu/products/edit.blade.php"
echo ""
echo "Voir INTERFACE_WEB_GUIDE.md pour les templates complets"
EOF

chmod +x /Users/Zhuanz/Desktop/projets/web/resto/create-all-views.sh

