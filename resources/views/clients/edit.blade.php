@extends('layouts.app')
@section('title', 'Modifier Client')
@section('content')
<div class="card">
    <div class="card-header"><h5>✏️ Modifier {{ $client->nom_complet }}</h5></div>
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
        
        <form action="{{ route('clients.update', $client) }}" method="POST">
            @csrf @method('PUT')
            
            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label">Nom *</label>
                    <input type="text" name="nom" class="form-control" value="{{ old('nom', $client->nom) }}" required>
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label">Prénom *</label>
                    <input type="text" name="prenom" class="form-control" value="{{ old('prenom', $client->prenom) }}" required>
                </div>
            </div>
            
            <div class="row">
                <div class="col-md-6 mb-3">
                    <label class="form-label">Téléphone *</label>
                    <input type="text" name="telephone" class="form-control" value="{{ old('telephone', $client->telephone) }}" required>
                </div>
                <div class="col-md-6 mb-3">
                    <label class="form-label">Email</label>
                    <input type="email" name="email" class="form-control" value="{{ old('email', $client->email) }}">
                </div>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Date de Naissance</label>
                <input type="date" name="date_naissance" class="form-control" value="{{ old('date_naissance', $client->date_naissance?->format('Y-m-d')) }}">
            </div>
            
            <div class="mb-3">
                <label class="form-label">Adresse</label>
                <textarea name="adresse" class="form-control" rows="3">{{ old('adresse', $client->adresse) }}</textarea>
            </div>
            
            <div class="mb-3">
                <div class="form-check">
                    <input type="checkbox" name="actif" class="form-check-input" id="actif" {{ old('actif', $client->actif) ? 'checked' : '' }}>
                    <label class="form-check-label" for="actif">Client Actif</label>
                </div>
            </div>
            
            <div class="d-flex justify-content-between">
                <a href="{{ route('clients.index') }}" class="btn btn-secondary">Retour</a>
                <button type="submit" class="btn btn-primary">Enregistrer</button>
            </div>
        </form>
    </div>
</div>
@endsection

