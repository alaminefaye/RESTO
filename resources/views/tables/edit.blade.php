@extends('layouts.app')

@section('title', 'Modifier une Table')

@section('content')
<div class="row">
    <div class="col-md-8 mx-auto">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">✏️ Modifier la Table {{ $table->numero }}</h5>
            </div>
            <div class="card-body">
                <form action="{{ route('tables.update', $table) }}" method="POST">
                    @csrf
                    @method('PUT')
                    
                    <div class="mb-3">
                        <label for="numero" class="form-label">Numéro de Table *</label>
                        <input type="text" class="form-control @error('numero') is-invalid @enderror" 
                               id="numero" name="numero" value="{{ old('numero', $table->numero) }}" required>
                        @error('numero')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    
                    <div class="mb-3">
                        <label for="type" class="form-label">Type de Table *</label>
                        <select class="form-select @error('type') is-invalid @enderror" id="type" name="type" required>
                            @foreach($types as $type)
                                <option value="{{ $type->value }}" {{ old('type', $table->type->value) == $type->value ? 'selected' : '' }}>
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
                               id="capacite" name="capacite" value="{{ old('capacite', $table->capacite) }}" 
                               min="1" required>
                        @error('capacite')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    
                    <div class="mb-3">
                        <label for="statut" class="form-label">Statut *</label>
                        <select class="form-select @error('statut') is-invalid @enderror" id="statut" name="statut" required>
                            @foreach($statuts as $statut)
                                <option value="{{ $statut->value }}" {{ old('statut', $table->statut->value) == $statut->value ? 'selected' : '' }}>
                                    @switch($statut->value)
                                        @case('libre') Libre @break
                                        @case('occupee') Occupée @break
                                        @case('reservee') Réservée @break
                                        @case('en_paiement') En Paiement @break
                                    @endswitch
                                </option>
                            @endforeach
                        </select>
                        @error('statut')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    
                    <div class="mb-3">
                        <label for="prix" class="form-label">Prix (pour VIP)</label>
                        <input type="number" class="form-control @error('prix') is-invalid @enderror" 
                               id="prix" name="prix" value="{{ old('prix', $table->prix) }}" step="0.01">
                        @error('prix')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    
                    <div class="mb-3">
                        <label for="prix_par_heure" class="form-label">Prix par Heure (pour Espace Jeux)</label>
                        <input type="number" class="form-control @error('prix_par_heure') is-invalid @enderror" 
                               id="prix_par_heure" name="prix_par_heure" value="{{ old('prix_par_heure', $table->prix_par_heure) }}" step="0.01">
                        @error('prix_par_heure')
                            <div class="invalid-feedback">{{ $message }}</div>
                        @enderror
                    </div>
                    
                    <div class="d-flex justify-content-between">
                        <a href="{{ route('tables.index') }}" class="btn btn-label-secondary">
                            <i class="bx bx-arrow-back"></i> Retour
                        </a>
                        <button type="submit" class="btn btn-primary">
                            <i class="bx bx-save"></i> Enregistrer
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>
@endsection

