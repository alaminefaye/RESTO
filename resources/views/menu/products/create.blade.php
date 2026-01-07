@extends('layouts.app')
@section('title', 'Nouveau Produit')
@section('content')
<div class="card">
    <div class="card-header"><h5>➕ Nouveau Produit</h5></div>
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
        
        <form action="{{ route('menu.products.store') }}" method="POST" enctype="multipart/form-data">
            @csrf
            
            <div class="mb-3">
                <label class="form-label">Catégorie *</label>
                <select name="categorie_id" class="form-select @error('categorie_id') is-invalid @enderror" required>
                    <option value="">Sélectionner une catégorie</option>
                    @foreach($categories as $category)
                        <option value="{{ $category->id }}" {{ old('categorie_id') == $category->id ? 'selected' : '' }}>
                            {{ $category->nom }}
                        </option>
                    @endforeach
                </select>
                @error('categorie_id')<div class="invalid-feedback">{{ $message }}</div>@enderror
            </div>
            
            <div class="mb-3">
                <label class="form-label">Nom du Produit *</label>
                <input type="text" name="nom" class="form-control @error('nom') is-invalid @enderror" value="{{ old('nom') }}" required>
                @error('nom')<div class="invalid-feedback">{{ $message }}</div>@enderror
            </div>
            
            <div class="mb-3">
                <label class="form-label">Description</label>
                <textarea name="description" class="form-control" rows="3">{{ old('description') }}</textarea>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Prix (FCFA) *</label>
                <input type="number" name="prix" class="form-control @error('prix') is-invalid @enderror" value="{{ old('prix') }}" min="0" step="0.01" required>
                @error('prix')<div class="invalid-feedback">{{ $message }}</div>@enderror
            </div>
            
            <div class="mb-3">
                <label class="form-label">Image</label>
                <input type="file" name="image" class="form-control @error('image') is-invalid @enderror" accept="image/*">
                @error('image')<div class="invalid-feedback">{{ $message }}</div>@enderror
                <small class="text-muted">Formats acceptés: JPG, PNG, GIF (max 2 Mo)</small>
            </div>
            
            <div class="mb-3">
                <div class="form-check">
                    <input type="checkbox" name="disponible" class="form-check-input" id="disponible" checked>
                    <label class="form-check-label" for="disponible">Disponible en stock</label>
                </div>
            </div>
            
            <div class="mb-3">
                <div class="form-check">
                    <input type="checkbox" name="actif" class="form-check-input" id="actif" checked>
                    <label class="form-check-label" for="actif">Actif</label>
                </div>
            </div>
            
            <div class="d-flex justify-content-between">
                <a href="{{ route('menu.products.index') }}" class="btn btn-secondary">Retour</a>
                <button type="submit" class="btn btn-primary">Créer</button>
            </div>
        </form>
    </div>
</div>
@endsection

