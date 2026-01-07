@extends('layouts.app')
@section('title', 'Commandes')
@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between">
        <h5 class="mb-0">📝 Commandes</h5>
        <a href="{{ route('commandes.create') }}" class="btn btn-primary"><i class="bx bx-plus"></i> Nouvelle Commande</a>
    </div>
    <div class="card-body">
        <!-- 🔍 SECTION RECHERCHE & FILTRES -->
        <div class="row mb-4">
            <div class="col-md-3 mb-3">
                <div class="input-group">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" id="searchInput" class="form-control" placeholder="Rechercher par #ID...">
                </div>
            </div>
            
            <div class="col-md-3 mb-3">
                <select id="filterTable" class="form-select">
                    <option value="">🪑 Toutes les tables</option>
                    @foreach(\App\Models\Table::orderBy('numero')->get() as $tbl)
                        <option value="{{ $tbl->numero }}">Table {{ $tbl->numero }}</option>
                    @endforeach
                </select>
            </div>
            
            <div class="col-md-3 mb-3">
                <select id="filterStatut" class="form-select">
                    <option value="">📊 Tous statuts</option>
                    <option value="attente">⏳ En attente</option>
                    <option value="preparation">🔄 En préparation</option>
                    <option value="servie">🍽️ Servie</option>
                    <option value="terminee">✅ Terminée</option>
                    <option value="annulee">❌ Annulée</option>
                </select>
            </div>
            
            <div class="col-md-3 mb-3">
                <button id="resetFilters" class="btn btn-outline-secondary w-100">
                    <i class="bx bx-reset"></i> Réinitialiser
                </button>
            </div>
        </div>
        
        <!-- Résultats de recherche -->
        <div id="searchResults" class="alert alert-info d-none mb-3">
            <i class="bx bx-info-circle"></i> <span id="resultCount">0</span> commande(s) trouvée(s)
        </div>
        
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Table</th>
                        <th>Serveur</th>
                        <th>Articles</th>
                        <th>Montant</th>
                        <th>Statut</th>
                        <th>Date</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="commandesTableBody">
                    @forelse($commandes as $commande)
                    <tr>
                        <td><strong>#{{ $commande->id }}</strong></td>
                        <td><span class="badge bg-primary">{{ $commande->table->numero }}</span></td>
                        <td>{{ $commande->user->name ?? 'N/A' }}</td>
                        <td>{{ $commande->produits->count() }} article(s)</td>
                        <td><strong>{{ number_format($commande->montant_total, 0, ',', ' ') }} FCFA</strong></td>
                        <td>
                            @switch($commande->statut->value)
                                @case('attente')
                                    <span class="badge bg-warning">En attente</span>
                                    @break
                                @case('preparation')
                                    <span class="badge bg-info">En préparation</span>
                                    @break
                                @case('servie')
                                    <span class="badge bg-primary">Servie</span>
                                    @break
                                @case('terminee')
                                    <span class="badge bg-success">Terminée</span>
                                    @break
                                @case('annulee')
                                    <span class="badge bg-danger">Annulée</span>
                                    @break
                            @endswitch
                        </td>
                        <td>{{ $commande->created_at->format('d/m/Y H:i') }}</td>
                        <td>
                            <a href="{{ route('commandes.show', $commande) }}" class="btn btn-sm btn-info" title="Voir"><i class="bx bx-show"></i></a>
                            @if($commande->statut->value !== 'terminee' && $commande->statut->value !== 'annulee')
                                <a href="{{ route('commandes.edit', $commande) }}" class="btn btn-sm btn-warning" title="Modifier"><i class="bx bx-edit"></i></a>
                            @endif
                        </td>
                    </tr>
                    @empty
                    <tr class="no-results">
                        <td colspan="8" class="text-center text-muted">Aucune commande trouvée</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</div>
@endsection

@push('page-js')
<script>
document.addEventListener('DOMContentLoaded', function() {
    const searchInput = document.getElementById('searchInput');
    const filterTable = document.getElementById('filterTable');
    const filterStatut = document.getElementById('filterStatut');
    const resetBtn = document.getElementById('resetFilters');
    const tableBody = document.getElementById('commandesTableBody');
    const searchResults = document.getElementById('searchResults');
    const resultCount = document.getElementById('resultCount');
    const allRows = tableBody.querySelectorAll('tr:not(.no-results)');
    
    function filterCommandes() {
        const searchTerm = searchInput.value.toLowerCase();
        const tableFilter = filterTable.value.toLowerCase();
        const statutFilter = filterStatut.value.toLowerCase();
        let visibleCount = 0;
        
        allRows.forEach(row => {
            const id = row.querySelector('td:nth-child(1)').textContent.toLowerCase();
            const table = row.querySelector('td:nth-child(2)').textContent.toLowerCase();
            const statut = row.querySelector('td:nth-child(6)').textContent.toLowerCase();
            
            const matchSearch = id.includes(searchTerm);
            const matchTable = !tableFilter || table.includes(tableFilter);
            const matchStatut = !statutFilter || statut.includes(statutFilter);
            
            if (matchSearch && matchTable && matchStatut) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });
        
        if (searchTerm || tableFilter || statutFilter) {
            searchResults.classList.remove('d-none');
            resultCount.textContent = visibleCount;
        } else {
            searchResults.classList.add('d-none');
        }
    }
    
    searchInput.addEventListener('keyup', filterCommandes);
    filterTable.addEventListener('change', filterCommandes);
    filterStatut.addEventListener('change', filterCommandes);
    
    resetBtn.addEventListener('click', function() {
        searchInput.value = '';
        filterTable.value = '';
        filterStatut.value = '';
        searchResults.classList.add('d-none');
        allRows.forEach(row => row.style.display = '');
    });
});
</script>
@endpush

