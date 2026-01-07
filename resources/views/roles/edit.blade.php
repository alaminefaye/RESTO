@extends('layouts.app')
@section('title', 'Modifier Rôle')
@section('content')
<div class="card">
    <div class="card-header"><h5>✏️ Modifier {{ ucfirst($role->name) }}</h5></div>
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
        
        @if($role->name === 'admin')
            <div class="alert alert-warning">
                <i class="bx bx-info-circle"></i> Le rôle <strong>admin</strong> est protégé. Vous pouvez modifier ses permissions mais pas son nom.
            </div>
        @endif
        
        <form action="{{ route('roles.update', $role) }}" method="POST">
            @csrf @method('PUT')
            
            <div class="mb-4">
                <label class="form-label">Nom du Rôle *</label>
                <input type="text" name="name" class="form-control" value="{{ old('name', $role->name) }}" {{ $role->name === 'admin' ? 'readonly' : '' }} required>
            </div>
            
            <h6 class="mb-3">Permissions</h6>
            
            @foreach($permissions as $group => $groupPermissions)
                <div class="mb-4">
                    <h6 class="text-primary">
                        {{ ucfirst($group) }}
                        <small class="text-muted">
                            (<span id="count_{{ $group }}">{{ $groupPermissions->whereIn('name', $rolePermissions)->count() }}</span>/{{ $groupPermissions->count() }})
                        </small>
                    </h6>
                    <div class="row">
                        @foreach($groupPermissions as $permission)
                            <div class="col-md-6 col-lg-4">
                                <div class="form-check">
                                    <input type="checkbox" name="permissions[]" value="{{ $permission->name }}" class="form-check-input group-{{ $group }}" id="perm_{{ $permission->id }}" 
                                           {{ in_array($permission->name, $rolePermissions) ? 'checked' : '' }}>
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
                <button type="submit" class="btn btn-primary">Enregistrer</button>
            </div>
        </form>
    </div>
</div>
@endsection

