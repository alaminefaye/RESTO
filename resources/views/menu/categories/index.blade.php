@extends('layouts.app')
@section('title', 'Catégories')
@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between">
        <h5 class="mb-0">📑 Catégories</h5>
        <a href="{{ route('menu.categories.create') }}" class="btn btn-primary"><i class="bx bx-plus"></i> Nouvelle</a>
    </div>
    <div class="card-body">
        <!-- 🔍 SECTION RECHERCHE & FILTRES -->
        <div class="row mb-4">
            <div class="col-md-8 mb-3">
                <div class="input-group">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" id="searchInput" class="form-control" placeholder="Rechercher par nom...">
                </div>
            </div>
            
            <div class="col-md-2 mb-3">
                <select id="filterStatut" class="form-select">
                    <option value="">📊 Tous</option>
                    <option value="actif">✅ Actif</option>
                    <option value="inactif">❌ Inactif</option>
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
            <i class="bx bx-info-circle"></i> <span id="resultCount">0</span> catégorie(s) trouvée(s)
        </div>
        
        <div class="table-responsive">
            <table class="table table-hover">
                <thead><tr><th>Nom</th><th>Produits</th><th>Ordre</th><th>Statut</th><th>Actions</th></tr></thead>
                <tbody id="categoriesTableBody">
                    @foreach($categories as $category)
                    <tr>
                        <td><strong>{{ $category->nom }}</strong></td>
                        <td><span class="badge bg-info">{{ $category->produits_count }}</span></td>
                        <td>{{ $category->ordre }}</td>
                        <td>
                            @if($category->actif)
                                <span class="badge bg-success">Actif</span>
                            @else
                                <span class="badge bg-secondary">Inactif</span>
                            @endif
                        </td>
                        <td>
                            <a href="{{ route('menu.categories.edit', $category) }}" class="btn btn-sm btn-warning"><i class="bx bx-edit"></i></a>
                            <form action="{{ route('menu.categories.destroy', $category) }}" method="POST" style="display:inline;" onsubmit="return confirm('Supprimer ?')">
                                @csrf @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-danger"><i class="bx bx-trash"></i></button>
                            </form>
                        </td>
                    </tr>
                    @endforeach
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
    const filterStatut = document.getElementById('filterStatut');
    const resetBtn = document.getElementById('resetFilters');
    const tableBody = document.getElementById('categoriesTableBody');
    const searchResults = document.getElementById('searchResults');
    const resultCount = document.getElementById('resultCount');
    const allRows = tableBody.querySelectorAll('tr');
    
    function filterCategories() {
        const searchTerm = searchInput.value.toLowerCase();
        const statutFilter = filterStatut.value.toLowerCase();
        let visibleCount = 0;
        
        allRows.forEach(row => {
            const nom = row.querySelector('td:nth-child(1)').textContent.toLowerCase();
            const statut = row.querySelector('td:nth-child(4)').textContent.toLowerCase();
            
            const matchSearch = nom.includes(searchTerm);
            const matchStatut = !statutFilter || statut.includes(statutFilter);
            
            if (matchSearch && matchStatut) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });
        
        if (searchTerm || statutFilter) {
            searchResults.classList.remove('d-none');
            resultCount.textContent = visibleCount;
        } else {
            searchResults.classList.add('d-none');
        }
    }
    
    searchInput.addEventListener('keyup', filterCategories);
    filterStatut.addEventListener('change', filterCategories);
    
    resetBtn.addEventListener('click', function() {
        searchInput.value = '';
        filterStatut.value = '';
        searchResults.classList.add('d-none');
        allRows.forEach(row => row.style.display = '');
    });
});
</script>
@endpush
