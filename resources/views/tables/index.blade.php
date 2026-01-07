@extends('layouts.app')

@section('title', 'Gestion des Tables')

@section('content')
<div class="row mb-4">
    <div class="col-12">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">📊 Statistiques Tables</h5>
            </div>
            <div class="card-body">
                <div class="row text-center">
                    <div class="col-md-3">
                        <h3 class="text-primary">{{ $stats['total'] }}</h3>
                        <p class="text-muted mb-0">Total</p>
                    </div>
                    <div class="col-md-3">
                        <h3 class="text-success">{{ $stats['libres'] }}</h3>
                        <p class="text-muted mb-0">Libres</p>
                    </div>
                    <div class="col-md-3">
                        <h3 class="text-danger">{{ $stats['occupees'] }}</h3>
                        <p class="text-muted mb-0">Occupées</p>
                    </div>
                    <div class="col-md-3">
                        <h3 class="text-warning">{{ $stats['reservees'] }}</h3>
                        <p class="text-muted mb-0">Réservées</p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<div class="row">
    <div class="col-12">
        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">🪑 Liste des Tables</h5>
                <a href="{{ route('tables.create') }}" class="btn btn-primary">
                    <i class="bx bx-plus"></i> Nouvelle Table
                </a>
            </div>
            <div class="card-body">
                <!-- 🔍 SECTION RECHERCHE & FILTRES -->
                <div class="row mb-4">
                    <div class="col-md-4 mb-3">
                        <div class="input-group">
                            <span class="input-group-text"><i class="bx bx-search"></i></span>
                            <input type="text" id="searchInput" class="form-control" placeholder="Rechercher par numéro...">
                        </div>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <select id="filterType" class="form-select">
                            <option value="">🏷️ Tous les types</option>
                            <option value="simple">Simple</option>
                            <option value="vip">VIP</option>
                            <option value="espace_jeux">Espace Jeux</option>
                        </select>
                    </div>
                    
                    <div class="col-md-3 mb-3">
                        <select id="filterStatut" class="form-select">
                            <option value="">📊 Tous les statuts</option>
                            <option value="libre">🟢 Libre</option>
                            <option value="occupee">🔴 Occupée</option>
                            <option value="reservee">🟡 Réservée</option>
                            <option value="en_paiement">🔵 En paiement</option>
                        </select>
                    </div>
                    
                    <div class="col-md-2 mb-3">
                        <button id="resetFilters" class="btn btn-outline-secondary w-100">
                            <i class="bx bx-reset"></i> Réinitialiser
                        </button>
                    </div>
                </div>
                
                <!-- Résultats de recherche -->
                <div id="searchResults" class="alert alert-info d-none mb-3">
                    <i class="bx bx-info-circle"></i> <span id="resultCount">0</span> table(s) trouvée(s)
                </div>
                
                <div class="table-responsive">
                    <table class="table table-hover">
                        <thead>
                            <tr>
                                <th>Numéro</th>
                                <th>Type</th>
                                <th>Capacité</th>
                                <th>Prix</th>
                                <th>Statut</th>
                                <th class="text-center">Actions</th>
                            </tr>
                        </thead>
                        <tbody id="tablesTableBody">
                            @forelse($tables as $table)
                                <tr>
                                    <td><strong class="text-primary">{{ $table->numero }}</strong></td>
                                    <td>
                                        @switch($table->type->value)
                                            @case('simple')
                                                <span class="badge bg-label-secondary">Simple</span>
                                                @break
                                            @case('vip')
                                                <span class="badge bg-label-warning">VIP</span>
                                                @break
                                            @case('espace_jeux')
                                                <span class="badge bg-label-info">Espace Jeux</span>
                                                @break
                                        @endswitch
                                    </td>
                                    <td>{{ $table->capacite }} pers.</td>
                                    <td>
                                        @if($table->prix)
                                            {{ number_format($table->prix, 0, ',', ' ') }} FCFA
                                        @elseif($table->prix_par_heure)
                                            {{ number_format($table->prix_par_heure, 0, ',', ' ') }} FCFA/h
                                        @else
                                            -
                                        @endif
                                    </td>
                                    <td>
                                        @switch($table->statut->value)
                                            @case('libre')
                                                <span class="badge bg-success">Libre</span>
                                                @break
                                            @case('occupee')
                                                <span class="badge bg-danger">Occupée</span>
                                                @break
                                            @case('reservee')
                                                <span class="badge bg-warning">Réservée</span>
                                                @break
                                            @case('en_paiement')
                                                <span class="badge bg-info">En paiement</span>
                                                @break
                                        @endswitch
                                    </td>
                                    <td class="text-center">
                                        <div class="btn-group" role="group">
                                            <a href="{{ route('tables.show', $table) }}" class="btn btn-sm btn-info" title="Voir">
                                                <i class="bx bx-show"></i>
                                            </a>
                                            <a href="{{ route('tables.edit', $table) }}" class="btn btn-sm btn-warning" title="Modifier">
                                                <i class="bx bx-edit"></i>
                                            </a>
                                            <form action="{{ route('tables.destroy', $table) }}" method="POST" style="display:inline;" onsubmit="return confirm('Supprimer cette table ?')">
                                                @csrf
                                                @method('DELETE')
                                                <button type="submit" class="btn btn-sm btn-danger" title="Supprimer">
                                                    <i class="bx bx-trash"></i>
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            @empty
                                <tr>
                                    <td colspan="6" class="text-center text-muted py-4">
                                        Aucune table trouvée. 
                                        <a href="{{ route('tables.create') }}">Créez-en une</a>
                                    </td>
                                </tr>
                            @endforelse
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>
</div>
@endsection

@push('page-js')
<script>
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('searchInput');
    const filterType = document.getElementById('filterType');
    const filterStatut = document.getElementById('filterStatut');
    const resetBtn = document.getElementById('resetFilters');
    const tableBody = document.getElementById('tablesTableBody');
    const searchResults = document.getElementById('searchResults');
    const resultCount = document.getElementById('resultCount');
    const allRows = tableBody.querySelectorAll('tr');
    
    // Fonction de filtrage
    function filterTables() {
        const searchTerm = searchInput.value.toLowerCase();
        const typeFilter = filterType.value.toLowerCase();
        const statutFilter = filterStatut.value.toLowerCase();
        let visibleCount = 0;
        
        allRows.forEach(row => {
            // Ignorer la ligne "Aucune table"
            if (row.querySelector('td[colspan]')) {
                row.style.display = 'none';
                return;
            }
            
            const numero = row.querySelector('td:nth-child(1)').textContent.toLowerCase();
            const type = row.querySelector('td:nth-child(2)').textContent.toLowerCase();
            const statut = row.querySelector('td:nth-child(5)').textContent.toLowerCase();
            
            const matchSearch = numero.includes(searchTerm);
            const matchType = !typeFilter || type.includes(typeFilter);
            const matchStatut = !statutFilter || statut.includes(statutFilter);
            
            if (matchSearch && matchType && matchStatut) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });
        
        // Afficher le nombre de résultats
        if (searchTerm || typeFilter || statutFilter) {
            searchResults.classList.remove('d-none');
            resultCount.textContent = visibleCount;
        } else {
            searchResults.classList.add('d-none');
        }
    }
    
    // Écouteurs d'événements
    searchInput.addEventListener('keyup', filterTables);
    filterType.addEventListener('change', filterTables);
    filterStatut.addEventListener('change', filterTables);
    
    // Réinitialiser les filtres
    resetBtn.addEventListener('click', function() {
        searchInput.value = '';
        filterType.value = '';
        filterStatut.value = '';
        searchResults.classList.add('d-none');
        allRows.forEach(row => row.style.display = '');
    });
});
</script>
@endpush

