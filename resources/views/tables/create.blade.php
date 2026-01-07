@extends('layouts.app')

@section('title', 'Créer une Table')

@section('content')
<div class="row">
    <div class="col-md-8 mx-auto">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">➕ Créer une Nouvelle Table</h5>
            </div>
            <div class="card-body">
                <form action="{{ route('tables.store') }}" method="POST">
                    @csrf
                    
                    <div class="mb-3">
                        <label for="numero" class="form-label">Numéro de Table *</label>
                        <input type="text" class="form-control @error('numero') is-invalid @enderror" 
                               id="numero" name="numero" value="{{ old('numero') }}" 
                               placeholder="Ex: T1, VIP1, JEU1" required>
                        @error('numero')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    
                    <div class="mb-3">
                        <label for="type" class="form-label">Type de Table *</label>
                        <select class="form-select @error('type') is-invalid @enderror" 
                                id="type" name="type" required>
                            <option value="">-- Choisir un type --</option>
                            @foreach($types as $type)
                                <option value="{{ $type->value }}" {{ old('type') == $type->value ? 'selected' : '' }}>
                                    @switch($type->value)
                                        @case('simple') Table Simple @break
                                        @case('vip') Table VIP @break
                                        @case('espace_jeux') Espace Jeux @break
                                    @endswitch
                                </option>
                            @endforeach
                        </select>
                        @error('type')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    
                    <div class="mb-3">
                        <label for="capacite" class="form-label">Capacité (nombre de personnes) *</label>
                        <input type="number" class="form-control @error('capacite') is-invalid @enderror" 
                               id="capacite" name="capacite" value="{{ old('capacite', 4) }}" 
                               min="1" required>
                        @error('capacite')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    
                    <div class="mb-3">
                        <label for="prix" class="form-label">Prix (pour VIP)</label>
                        <input type="number" class="form-control @error('prix') is-invalid @enderror" 
                               id="prix" name="prix" value="{{ old('prix') }}" 
                               placeholder="Prix fixe pour table VIP" step="0.01">
                        @error('prix')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                        <small class="form-text text-muted">Laissez vide pour les tables simples</small>
                    </div>
                    
                    <div class="mb-3">
                        <label for="prix_par_heure" class="form-label">Prix par Heure (pour Espace Jeux)</label>
                        <input type="number" class="form-control @error('prix_par_heure') is-invalid @enderror" 
                               id="prix_par_heure" name="prix_par_heure" value="{{ old('prix_par_heure') }}" 
                               placeholder="Prix par heure pour espace jeux" step="0.01">
                        @error('prix_par_heure')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                        <small class="form-text text-muted">Pour les espaces jeux uniquement</small>
                    </div>
                    
                    <div class="d-flex justify-content-between">
                        <a href="{{ route('tables.index') }}" class="btn btn-label-secondary">
                            <i class="bx bx-arrow-back"></i> Retour
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="bx bx-save"></i> Créer la Table
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection

