@extends('layouts.app')
@section('title', 'Nouvelle Catégorie')
@section('content')
<div class="card">
    <div class="card-header"><h5>➕ Nouvelle Catégorie</h5></div>
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
        
        <form action="{{ route('menu.categories.store') }}" method="POST">
            @csrf
            <div class="mb-3">
                <label class="form-label">Nom *</label>
                <input type="text" name="nom" class="form-control @error('nom') is-invalid @enderror" value="{{ old('nom') }}" required>
                @error('nom')<div class="invalid-feedback">{{ $message }}</div>@enderror
            </div>
            <div class="mb-3">
                <label class="form-label">Description</label>
                <textarea name="description" class="form-control" rows="3">{{ old('description') }}</textarea>
            </div>
            <div class="mb-3">
                <label class="form-label">Ordre</label>
                <input type="number" name="ordre" class="form-control" value="{{ old('ordre', 0) }}">
            </div>
            <div class="mb-3">
                <div class="form-check">
                    <input type="checkbox" name="actif" class="form-check-input" id="actif" checked>
                    <label class="form-check-label" for="actif">Active</label>
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
