@extends('layouts.app')
@section('title', 'Modifier Catégorie')
@section('content')
<div class="card">
    <div class="card-header"><h5>✏️ Modifier {{ $category->nom }}</h5></div>
    <div class="card-body">
        <form action="{{ route('menu.categories.update', $category) }}" method="POST">
            @csrf @method('PUT')
            <div class="mb-3">
                <label class="form-label">Nom *</label>
                <input type="text" name="nom" class="form-control" value="{{ old('nom', $category->nom) }}" required>
            </div>
            <div class="mb-3">
                <label class="form-label">Description</label>
                <textarea name="description" class="form-control" rows="3">{{ old('description', $category->description) }}</textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">Ordre</label>
                <input type="number" name="ordre" class="form-control" value="{{ old('ordre', $category->ordre) }}">
            </div>
            <div class="mb-3">
                <div class="form-check">
                    <input type="checkbox" name="actif" class="form-check-input" id="actif" {{ old('actif', $category->actif) ? 'checked' : '' }}>
                    <label class="form-check-label" for="actif">Active</label>
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
