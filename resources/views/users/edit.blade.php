@extends('layouts.app')
@section('title', 'Modifier Utilisateur')
@section('content')
<div class="card">
    <div class="card-header"><h5>✏️ Modifier {{ $user->name }}</h5></div>
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
        
        <form action="{{ route('users.update', $user) }}" method="POST">
            @csrf @method('PUT')
            
            <div class="mb-3">
                <label class="form-label">Nom Complet *</label>
                <input type="text" name="name" class="form-control" value="{{ old('name', $user->name) }}" required>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Email *</label>
                <input type="email" name="email" class="form-control" value="{{ old('email', $user->email) }}" required>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Nouveau Mot de Passe <small class="text-muted">(laisser vide pour ne pas changer)</small></label>
                <input type="password" name="password" class="form-control">
            </div>
            
            <div class="mb-3">
                <label class="form-label">Confirmer Nouveau Mot de Passe</label>
                <input type="password" name="password_confirmation" class="form-control">
            </div>
            
            <div class="mb-3">
                <label class="form-label">Rôles *</label>
                @foreach($roles as $role)
                    <div class="form-check">
                        <input type="checkbox" name="roles[]" value="{{ $role->name }}" class="form-check-input" id="role_{{ $role->id }}" 
                               {{ $user->hasRole($role->name) ? 'checked' : '' }}>
                        <label class="form-check-label" for="role_{{ $role->id }}">
                            <strong>{{ ucfirst($role->name) }}</strong>
                        </label>
                    </div>
                @endforeach
            </div>
            
            <div class="d-flex justify-content-between">
                <a href="{{ route('users.index') }}" class="btn btn-secondary">Retour</a>
                <button type="submit" class="btn btn-primary">Enregistrer</button>
            </div>
        </form>
    </div>
</div>
@endsection

