@extends('layouts.app')
@section('title', 'Nouveau Rôle')
@section('content')
<div class="card">
    <div class="card-header"><h5>➕ Nouveau Rôle</h5></div>
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
        
        <form action="{{ route('roles.store') }}" method="POST">
            @csrf
            
            <div class="mb-4">
                <label class="form-label">Nom du Rôle *</label>
                <input type="text" name="name" class="form-control" value="{{ old('name') }}" required placeholder="Ex: vendeur, cuisinier...">
            </div>
            
            <h6 class="mb-3">Permissions</h6>
            
            @foreach($permissions as $group => $groupPermissions)
                <div class="mb-4">
                    <h6 class="text-primary">{{ ucfirst($group) }}</h6>
                    <div class="row">
                        @foreach($groupPermissions as $permission)
                            <div class="col-md-6 col-lg-4">
                                <div class="form-check">
                                    <input type="checkbox" name="permissions[]" value="{{ $permission->name }}" class="form-check-input" id="perm_{{ $permission->id }}">
                                    <label class="form-check-label" for="perm_{{ $permission->id }}">
                                        {{ str_replace('_', ' ', $permission->name) }}
                                    </label>
                                </div>
                            </div>
                        @endforeach
                    </div>
                </div>
            @endforeach
            
            <div class="d-flex justify-content-between">
                <a href="{{ route('roles.index') }}" class="btn btn-secondary">Retour</a>
                <button type="submit" class="btn btn-primary">Créer</button>
            </div>
        </form>
    </div>
</div>
@endsection

