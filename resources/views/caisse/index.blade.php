@extends('layouts.app')
@section('title', 'Caisse')
@section('content')
<div class="card">
    <div class="card-header">
        <h5 class="mb-0">💰 Interface de Caisse</h5>
    </div>
    <div class="card-body">
        <h6 class="mb-3">Commandes en attente de paiement</h6>
        
        @if($commandesEnAttente->isEmpty())
            <div class="alert alert-info">
                <i class="bx bx-info-circle"></i> Aucune commande en attente de paiement
            </div>
        @else
            <!-- 🔍 SECTION RECHERCHE & FILTRES -->
            <div class="row mb-4">
                <div class="col-md-4 mb-3">
                    <div class="input-group">
                        <span class="input-group-text"><i class="bx bx-search"></i></span>
                        <input type="text" id="searchInput" class="form-control" placeholder="Rechercher par #ID ou Table...">
                    </div>
                </div>
                
                <div class="col-md-3 mb-3">
                    <select id="filterStatut" class="form-select">
                        <option value="">📊 Tous statuts</option>
                        <option value="attente">⏳ En attente</option>
                        <option value="preparation">🔄 En préparation</option>
                        <option value="servie">🍽️ Servie</option>
                    </select>
                </div>
                
                <div class="col-md-3 mb-3">
                    <select id="sortBy" class="form-select">
                        <option value="recent">🕐 Plus récent</option>
                        <option value="ancien">🕑 Plus ancien</option>
                        <option value="montant_desc">💰 Montant ↓</option>
                        <option value="montant_asc">💵 Montant ↑</option>
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
                <i class="bx bx-info-circle"></i> <span id="resultCount">0</span> commande(s) trouvée(s)
            </div>
            
            <div class="row" id="commandesContainer">
                @foreach($commandesEnAttente as $commande)
                <div class="col-md-6 col-lg-4 mb-3 commande-card" 
                     data-id="{{ $commande->id }}"
                     data-table="{{ $commande->table->numero }}"
                     data-statut="{{ $commande->statut->value }}"
                     data-montant="{{ $commande->montant_total }}"
                     data-date="{{ $commande->created_at->timestamp }}">
                    <div class="card border {{ $commande->statut->value === 'servie' ? 'border-primary' : 'border-secondary' }}">
                        <div class="card-header d-flex justify-content-between align-items-center">
                            <strong>Table {{ $commande->table->numero }}</strong>
                            @switch($commande->statut->value)
                                @case('attente')
                                    <span class="badge bg-warning">En attente</span>
                                    @break
                                @case('preparation')
                                    <span class="badge bg-info">En préparation</span>
                                    @break
                                @case('servie')
                                    <span class="badge bg-success">Servie</span>
                                    @break
                            @endswitch
                        </div>
                        <div class="card-body">
                            <div class="mb-2">
                                <small class="text-muted">Commande #{{ $commande->id }}</small>
                            </div>
                            
                            <div class="mb-2">
                                <strong>Articles :</strong>
                                <ul class="small mb-0">
                                    @foreach($commande->produits->take(3) as $produit)
                                        <li>{{ $produit->nom }} x{{ $produit->pivot->quantite }}</li>
                                    @endforeach
                                    @if($commande->produits->count() > 3)
                                        <li class="text-muted">+ {{ $commande->produits->count() - 3 }} autre(s)</li>
                                    @endif
                                </ul>
                            </div>
                            
                            <div class="mb-3">
                                <strong class="text-success h4">{{ number_format($commande->montant_total, 0, ',', ' ') }} FCFA</strong>
                            </div>
                            
                            <div class="d-flex gap-2">
                                <a href="{{ route('commandes.show', $commande) }}" class="btn btn-sm btn-outline-secondary flex-grow-1">
                                    <i class="bx bx-show"></i> Détails
                                </a>
                                <a href="{{ route('caisse.payer', $commande) }}" class="btn btn-sm btn-primary flex-grow-1">
                                    <i class="bx bx-money"></i> Payer
                                </a>
                            </div>
                        </div>
                        <div class="card-footer text-muted small">
                            <i class="bx bx-time"></i> {{ $commande->created_at->diffForHumans() }}
                        </div>
                    </div>
                </div>
                @endforeach
            </div>
        @endif
    </div>
</div>

<div class="card mt-3">
    <div class="card-header">
        <h6 class="mb-0">📊 Statistiques du jour</h6>
    </div>
    <div class="card-body">
        <div class="row">
            <div class="col-md-3">
                <div class="text-center">
                    <h3 class="text-primary">{{ $commandesEnAttente->count() }}</h3>
                    <p class="text-muted mb-0">Commandes en attente</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="text-center">
                    <h3 class="text-success">{{ number_format($commandesEnAttente->sum('montant_total'), 0, ',', ' ') }}</h3>
                    <p class="text-muted mb-0">Total à encaisser (FCFA)</p>
                </div>
            </div>
            <div class="col-md-3">
                <div class="text-center">
                    <a href="{{ route('caisse.historique') }}" class="btn btn-outline-primary">
                        <i class="bx bx-history"></i> Historique
                    </a>
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
    const filterStatut = document.getElementById('filterStatut');
    const sortBy = document.getElementById('sortBy');
    const resetBtn = document.getElementById('resetFilters');
    const container = document.getElementById('commandesContainer');
    const searchResults = document.getElementById('searchResults');
    const resultCount = document.getElementById('resultCount');
    const allCards = Array.from(document.querySelectorAll('.commande-card'));
    
    function filterAndSortCommandes() {
        const searchTerm = searchInput.value.toLowerCase();
        const statutFilter = filterStatut.value.toLowerCase();
        const sortOption = sortBy.value;
        let visibleCount = 0;
        let visibleCards = [];
        
        // Filtrage
        allCards.forEach(card => {
            const id = card.dataset.id;
            const table = card.dataset.table;
            const statut = card.dataset.statut;
            
            const matchSearch = !searchTerm || 
                                id.includes(searchTerm) || 
                                table.includes(searchTerm);
            const matchStatut = !statutFilter || statut.includes(statutFilter);
            
            if (matchSearch && matchStatut) {
                visibleCards.push(card);
                visibleCount++;
            } else {
                card.style.display = 'none';
            }
        });
        
        // Tri
        visibleCards.sort((a, b) => {
            switch(sortOption) {
                case 'ancien':
                    return parseInt(a.dataset.date) - parseInt(b.dataset.date);
                case 'montant_desc':
                    return parseFloat(b.dataset.montant) - parseFloat(a.dataset.montant);
                case 'montant_asc':
                    return parseFloat(a.dataset.montant) - parseFloat(b.dataset.montant);
                case 'recent':
                default:
                    return parseInt(b.dataset.date) - parseInt(a.dataset.date);
            }
        });
        
        // Réorganiser les cartes
        visibleCards.forEach(card => {
            card.style.display = '';
            container.appendChild(card);
        });
        
        // Afficher le compteur
        if (searchTerm || statutFilter) {
            searchResults.classList.remove('d-none');
            resultCount.textContent = visibleCount;
        } else {
            searchResults.classList.add('d-none');
        }
    }
    
    searchInput.addEventListener('keyup', filterAndSortCommandes);
    filterStatut.addEventListener('change', filterAndSortCommandes);
    sortBy.addEventListener('change', filterAndSortCommandes);
    
    resetBtn.addEventListener('click', function() {
        searchInput.value = '';
        filterStatut.value = '';
        sortBy.value = 'recent';
        searchResults.classList.add('d-none');
        filterAndSortCommandes();
    });
});
</script>
@endpush

