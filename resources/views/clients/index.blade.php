@extends('layouts.app')
@section('title', 'Clients')
@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between">
        <h5 class="mb-0">👥 Clients & Programme de Fidélité</h5>
        @can('manage_customers')
            <a href="{{ route('clients.create') }}" class="btn btn-primary"><i class="bx bx-plus"></i> Nouveau Client</a>
        @endcan
    </div>
    <div class="card-body">
        <table class="table">
            <thead>
                <tr>
                    <th>Nom Complet</th>
                    <th>Téléphone</th>
                    <th>Email</th>
                    <th>Points</th>
                    <th>Visites</th>
                    <th>Total Dépenses</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
                @forelse($clients as $client)
                <tr>
                    <td><strong>{{ $client->nom_complet }}</strong></td>
                    <td>{{ $client->telephone }}</td>
                    <td>{{ $client->email ?? '-' }}</td>
                    <td><span class="badge bg-success">{{ $client->points_fidelite }} pts</span></td>
                    <td>{{ $client->nombre_visites }}</td>
                    <td><strong>{{ number_format($client->total_depenses, 0, ',', ' ') }} FCFA</strong></td>
                    <td>
                        <a href="{{ route('clients.show', $client) }}" class="btn btn-sm btn-info" title="Voir"><i class="bx bx-show"></i></a>
                        @can('manage_customers')
                            <a href="{{ route('clients.edit', $client) }}" class="btn btn-sm btn-warning" title="Modifier"><i class="bx bx-edit"></i></a>
                            <form action="{{ route('clients.destroy', $client) }}" method="POST" style="display:inline;" onsubmit="return confirm('Supprimer ce client ?')">
                                @csrf @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-danger" title="Supprimer"><i class="bx bx-trash"></i></button>
                            </form>
                        @endcan
                    </td>
                </tr>
                @empty
                <tr>
                    <td colspan="7" class="text-center text-muted">Aucun client trouvé</td>
                </tr>
                @endforelse
            </tbody>
        </table>
        
        <div class="mt-3">
            {{ $clients->links() }}
        </div>
    </div>
</div>
@endsection

