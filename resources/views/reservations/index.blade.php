@extends('layouts.app')
@section('title', 'Réservations')
@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">📅 Réservations</h5>
        <a href="{{ route('reservations.create') }}" class="btn btn-primary"><i class="bx bx-plus"></i> Nouvelle Réservation</a>
    </div>
    <div class="card-body">
        @if(session('success'))
            <div class="alert alert-success alert-dismissible" role="alert">
                {{ session('success') }}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        @endif
        @if(session('error'))
            <div class="alert alert-danger alert-dismissible" role="alert">
                {{ session('error') }}
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        @endif

        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Client</th>
                        <th>Table</th>
                        <th>Date & Heure</th>
                        <th>Durée</th>
                        <th>Pers.</th>
                        <th>Prix</th>
                        <th>Statut</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    @forelse($reservations as $reservation)
                    <tr>
                        <td><strong>#{{ $reservation->id }}</strong></td>
                        <td>
                            <div class="d-flex flex-column">
                                <span class="fw-bold">{{ $reservation->nom_client }}</span>
                                <small class="text-muted">{{ $reservation->telephone }}</small>
                            </div>
                        </td>
                        <td>
                            @if($reservation->table)
                                <span class="badge bg-label-primary">Table {{ $reservation->table->numero }}</span>
                            @else
                                <span class="badge bg-label-danger">Table supprimée</span>
                            @endif
                        </td>
                        <td>
                            <div class="d-flex flex-column">
                                <span>{{ $reservation->date_reservation->format('d/m/Y') }}</span>
                                <small class="text-muted">{{ $reservation->heure_debut->format('H:i') }} - {{ $reservation->heure_fin ? $reservation->heure_fin->format('H:i') : '' }}</small>
                            </div>
                        </td>
                        <td>{{ $reservation->duree }}h</td>
                        <td>{{ $reservation->nombre_personnes }}</td>
                        <td>{{ number_format($reservation->prix_total, 0, ',', ' ') }} FCFA</td>
                        <td>
                            @switch($reservation->statut->value)
                                @case('attente')
                                    <span class="badge bg-warning">En attente</span>
                                    @break
                                @case('confirmee')
                                    <span class="badge bg-success">Confirmée</span>
                                    @break
                                @case('en_cours')
                                    <span class="badge bg-primary">En cours</span>
                                    @break
                                @case('terminee')
                                    <span class="badge bg-secondary">Terminée</span>
                                    @break
                                @case('annulee')
                                    <span class="badge bg-danger">Annulée</span>
                                    @break
                            @endswitch
                        </td>
                        <td>
                            <div class="dropdown">
                                <button type="button" class="btn p-0 dropdown-toggle hide-arrow" data-bs-toggle="dropdown">
                                    <i class="bx bx-dots-vertical-rounded"></i>
                                </button>
                                <div class="dropdown-menu">
                                    <a class="dropdown-item" href="{{ route('reservations.show', $reservation) }}">
                                        <i class="bx bx-show-alt me-1"></i> Détails
                                    </a>
                                    @if($reservation->statut->value === 'attente' || $reservation->statut->value === 'confirmee')
                                        <a class="dropdown-item" href="{{ route('reservations.edit', $reservation) }}">
                                            <i class="bx bx-edit-alt me-1"></i> Modifier
                                        </a>
                                    @endif
                                    
                                    @if($reservation->statut->value === 'attente')
                                        <form action="{{ route('reservations.confirm', $reservation) }}" method="POST" class="d-inline">
                                            @csrf
                                            <button type="submit" class="dropdown-item text-success">
                                                <i class="bx bx-check-circle me-1"></i> Confirmer
                                            </button>
                                        </form>
                                    @endif
                                    
                                    @if($reservation->statut->value !== 'annulee' && $reservation->statut->value !== 'terminee')
                                        <form action="{{ route('reservations.cancel', $reservation) }}" method="POST" class="d-inline" onsubmit="return confirm('Êtes-vous sûr de vouloir annuler cette réservation ?');">
                                            @csrf
                                            <button type="submit" class="dropdown-item text-danger">
                                                <i class="bx bx-x-circle me-1"></i> Annuler
                                            </button>
                                        </form>
                                    @endif
                                </div>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="9" class="text-center py-5">
                            <i class="bx bx-calendar-x fs-1 text-muted mb-2"></i>
                            <p class="text-muted">Aucune réservation trouvée.</p>
                        </td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
        
        <div class="mt-4">
            {{ $reservations->links() }}
        </div>
    </div>
</div>
@endsection
