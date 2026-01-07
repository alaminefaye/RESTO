@extends('layouts.app')
@section('title', 'Nouvel Utilisateur')
@section('content')
<div class="card">
    <div class="card-header"><h5>➕ Nouvel Utilisateur</h5></div>
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
        
        <form action="{{ route('users.store') }}" method="POST">
            @csrf
            
            <div class="mb-3">
                <label class="form-label">Nom Complet *</label>
                <input type="text" name="name" class="form-control @error('name') is-invalid @enderror" value="{{ old('name') }}" required>
                @error('name')<div class="invalid-feedback">{{ $message }}</div>@enderror
            </div>
            
            <div class="mb-3">
                <label class="form-label">Email *</label>
                <input type="email" name="email" class="form-control @error('email') is-invalid @enderror" value="{{ old('email') }}" required>
                @error('email')<div class="invalid-feedback">{{ $message }}</div>@enderror
            </div>
            
            <div class="mb-3">
                <label class="form-label">Mot de Passe *</label>
                <input type="password" name="password" class="form-control @error('password') is-invalid @enderror" required>
                @error('password')<div class="invalid-feedback">{{ $message }}</div>@enderror
            </div>
            
            <div class="mb-3">
                <label class="form-label">Confirmer Mot de Passe *</label>
                <input type="password" name="password_confirmation" class="form-control" required>
            </div>
            
            <div class="mb-3">
                <label class="form-label">Rôles *</label>
                @foreach($roles as $role)
                    <div class="form-check">
                        <input type="checkbox" name="roles[]" value="{{ $role->name }}" class="form-check-input" id="role_{{ $role->id }}" {{ in_array($role->name, old('roles', [])) ? 'checked' : '' }}>
                        <label class="form-check-label" for="role_{{ $role->id }}">
                            <strong>{{ ucfirst($role->name) }}</strong>
                        </label>
                    </div>
                @endforeach
                @error('roles')<div class="text-danger small">{{ $message }}</div>@enderror
            </div>
            
            <div class="d-flex justify-content-between">
                <a href="{{ route('users.index') }}" class="btn btn-secondary">Retour</a>
                <button type="submit" class="btn btn-primary">Créer</button>
            </div>
        </form>
    </div>
</div>
@endsection

