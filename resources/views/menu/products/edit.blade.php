@extends('layouts.app')
@section('title', 'Modifier Produit')
@section('content')
<div class="card">
    <div class="card-header"><h5>✏️ Modifier {{ $product->nom }}</h5></div>
    <div class="card-body">
        @if ($errors->any())
            <div class="alert alert-danger">
                <ul class="mb-0">
                    @foreach ($errors->all() as $error)
                        <li>{{ $error }}</li>
                    @endforeach
                </ul>
            </div>
        @endif
        
        <form action="{{ route('menu.products.update', $product) }}" method="POST" enctype="multipart/form-data">
            @csrf @method('PUT')
            
            <div class="mb-3">
                <label class="form-label">Catégorie *</label>
                <select name="categorie_id" class="form-select" required>
                    @foreach($categories as $category)
                        <option value="{{ $category->id }}" {{ old('categorie_id', $product->categorie_id) == $category->id ? 'selected' : '' }}>
                            {{ $category->nom }}
                        </option>
                    @endforeach
                </select>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Nom du Produit *</label>
                <input type="text" name="nom" class="form-control" value="{{ old('nom', $product->nom) }}" required>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Description</label>
                <textarea name="description" class="form-control" rows="3">{{ old('description', $product->description) }}</textarea>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Prix (FCFA) *</label>
                <input type="number" name="prix" class="form-control" value="{{ old('prix', $product->prix) }}" min="0" step="0.01" required>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Image</label>
                @if($product->image)
                    <div class="mb-2">
                        <img src="{{ $product->image_url }}" alt="{{ $product->nom }}" style="width: 150px; height: 150px; object-fit: cover; border-radius: 8px;">
                    </div>
                @endif
                <input type="file" name="image" class="form-control" accept="image/*">
                <small class="text-muted">Laisser vide pour conserver l'image actuelle</small>
            </div>
            
            <div class="mb-3">
                <div class="form-check">
                    <input type="checkbox" name="disponible" class="form-check-input" id="disponible" {{ old('disponible', $product->disponible) ? 'checked' : '' }}>
                    <label class="form-check-label" for="disponible">Disponible en stock</label>
                </div>
            </div>
            
            <div class="mb-3">
                <div class="form-check">
                    <input type="checkbox" name="actif" class="form-check-input" id="actif" {{ old('actif', $product->actif) ? 'checked' : '' }}>
                    <label class="form-check-label" for="actif">Actif</label>
                </div>
            </div>
            
            <div class="d-flex justify-content-between">
                <a href="{{ route('menu.products.index') }}" class="btn btn-secondary">Retour</a>
                <button type="submit" class="btn btn-primary">Enregistrer</button>
            </div>
        </form>
    </div>
</div>
@endsection

