@extends('layouts.app')
@section('title', 'Détails Rôle')
@section('content')
<div class="row">
    <div class="col-md-8">
        <div class="card">
            <div class="card-header d-flex justify-content-between">
                <h5 class="mb-0">🔐 {{ ucfirst($role->name) }}</h5>
                <div>
                    @can('manage_roles')
                        @if($role->name !== 'admin')
                            <a href="{{ route('roles.edit', $role) }}" class="btn btn-sm btn-warning">
                                <i class="bx bx-edit"></i> Modifier
                            </a>
                        @else
                            <a href="{{ route('roles.edit', $role) }}" class="btn btn-sm btn-warning">
                                <i class="bx bx-edit"></i> Gérer Permissions
                            </a>
                        @endif
                    @endcan
                    <a href="{{ route('roles.index') }}" class="btn btn-sm btn-label-secondary">
                        <i class="bx bx-arrow-back"></i> Retour
                    </a>
                </div>
            </div>
            <div class="card-body">
                <h6 class="mb-3">Permissions ({{ $role->permissions->count() }})</h6>
                
                @foreach($permissionsByGroup as $group => $groupPermissions)
                    <div class="mb-3">
                        <strong class="text-primary">{{ ucfirst($group) }}</strong>
                        <ul class="list-unstyled ms-3">
                            @foreach($groupPermissions as $permission)
                                <li><i class="bx bx-check text-success"></i> {{ str_replace('_', ' ', $permission->name) }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endforeach
                
                @if($role->permissions->count() === 0)
                    <p class="text-muted">Aucune permission assignée à ce rôle.</p>
                @endif
            </div>
        </div>
    </div>
    
    <div class="col-md-4">
        <div class="card">
            <div class="card-header"><h6 class="mb-0">Utilisateurs avec ce rôle</h6></div>
            <div class="card-body">
                @if($role->users->count() > 0)
                    <ul class="list-unstyled">
                        @foreach($role->users as $user)
                            <li class="mb-2">
                                <a href="{{ route('users.show', $user) }}">
                                    <i class="bx bx-user"></i> {{ $user->name }}
                                </a>
                            </li>
                        @endforeach
                    </ul>
                @else
                    <p class="text-muted">Aucun utilisateur n'a ce rôle.</p>
                @endif
            </div>
        </div>
    </div>
</div>
@endsection

