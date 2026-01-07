@extends('layouts.app')
@section('title', 'Détails Client')
@section('content')
<div class="row">
    <div class="col-md-8">
        <div class="card mb-4">
            <div class="card-header d-flex justify-content-between">
                <h5 class="mb-0">👤 {{ $client->nom_complet }}</h5>
                <div>
                    @can('manage_customers')
                        <a href="{{ route('clients.edit', $client) }}" class="btn btn-sm btn-warning">
                            <i class="bx bx-edit"></i> Modifier
                        </a>
                    @endcan
                    <a href="{{ route('clients.index') }}" class="btn btn-sm btn-label-secondary">
                        <i class="bx bx-arrow-back"></i> Retour
                    </a>
                </div>
            </div>
            <div class="card-body">
                <div class="row mb-3">
                    <div class="col-md-6">
                        <strong>Téléphone :</strong>
                        <p>{{ $client->telephone }}</p>
                    </div>
                    <div class="col-md-6">
                        <strong>Email :</strong>
                        <p>{{ $client->email ?? '-' }}</p>
                    </div>
                </div>
                
                <div class="row mb-3">
                    <div class="col-md-6">
                        <strong>Date de Naissance :</strong>
                        <p>{{ $client->date_naissance?->format('d/m/Y') ?? '-' }}</p>
                    </div>
                    <div class="col-md-6">
                        <strong>Inscrit le :</strong>
                        <p>{{ $client->date_inscription->format('d/m/Y') }}</p>
                    </div>
                </div>
                
                @if($client->adresse)
                    <div class="mb-3">
                        <strong>Adresse :</strong>
                        <p>{{ $client->adresse }}</p>
                    </div>
                @endif
                
                <hr>
                
                <h6 class="mb-3">Historique des Points</h6>
                <div class="table-responsive">
                    <table class="table table-sm">
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Type</th>
                                <th>Points</th>
                                <th>Description</th>
                            </tr>
                        </thead>
                        <tbody>
                            @forelse($client->historiquePoints->sortByDesc('created_at')->take(10) as $historique)
                            <tr>
                                <td>{{ $historique->created_at->format('d/m/Y H:i') }}</td>
                                <td>
                                    @if($historique->type === 'gain')
                                        <span class="badge bg-success">Gain</span>
                                    @elseif($historique->type === 'depense')
                                        <span class="badge bg-warning">Dépense</span>
                                    @else
                                        <span class="badge bg-info">Ajustement</span>
                                    @endif
                                </td>
                                <td><strong class="text-{{ $historique->points > 0 ? 'success' : 'danger' }}">
                                    {{ $historique->points > 0 ? '+' : '' }}{{ $historique->points }}
                                </strong></td>
                                <td>{{ $historique->description }}</td>
                            </tr>
                            @empty
                            <tr>
                                <td colspan="4" class="text-center text-muted">Aucun historique</td>
                            </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
    
    <div class="col-md-4">
        <div class="card mb-3">
            <div class="card-header"><h6 class="mb-0">💰 Programme de Fidélité</h6></div>
            <div class="card-body text-center">
                <h2 class="text-success mb-0">{{ $client->points_fidelite }}</h2>
                <p class="text-muted">Points Disponibles</p>
                <hr>
                <p class="mb-1"><strong>{{ $client->nombre_visites }}</strong> visites</p>
                <p class="mb-1"><strong>{{ number_format($client->total_depenses, 0, ',', ' ') }} FCFA</strong> dépensés</p>
                @if($client->date_derniere_visite)
                    <p class="text-muted small">Dernière visite : {{ $client->date_derniere_visite->format('d/m/Y') }}</p>
                @endif
            </div>
        </div>
        
        @can('manage_loyalty')
        <div class="card">
            <div class="card-header"><h6 class="mb-0">Ajuster les Points</h6></div>
            <div class="card-body">
                <form action="{{ route('clients.ajuster-points', $client) }}" method="POST">
                    @csrf
                    <div class="mb-3">
                        <label class="form-label">Points</label>
                        <input type="number" name="points" class="form-control" required>
                        <small class="text-muted">Positif pour ajouter, négatif pour retirer</small>
                    </div>
                    <div class="mb-3">
                        <label class="form-label">Description</label>
                        <input type="text" name="description" class="form-control" required>
                    </div>
                    <button type="submit" class="btn btn-primary w-100">Ajuster</button>
                </form>
            </div>
        </div>
        @endcan
    </div>
</div>
@endsection

