@extends('layouts.app')
@section('title', 'Produits')
@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between">
        <h5 class="mb-0">🍽️ Produits</h5>
        <a href="{{ route('menu.products.create') }}" class="btn btn-primary"><i class="bx bx-plus"></i> Nouveau Produit</a>
    </div>
    <div class="card-body">
        <!-- 🔍 SECTION RECHERCHE & FILTRES -->
        <div class="row mb-4">
            <div class="col-md-5 mb-3">
                <div class="input-group">
                    <span class="input-group-text"><i class="bx bx-search"></i></span>
                    <input type="text" id="searchInput" class="form-control" placeholder="Rechercher par nom...">
                </div>
            </div>
            
            <div class="col-md-3 mb-3">
                <select id="filterCategorie" class="form-select">
                    <option value="">📁 Toutes catégories</option>
                    @foreach(\App\Models\Category::where('actif', true)->orderBy('ordre')->get() as $cat)
                        <option value="{{ $cat->nom }}">{{ $cat->nom }}</option>
                    @endforeach
                </select>
            </div>
            
            <div class="col-md-2 mb-3">
                <select id="filterStatut" class="form-select">
                    <option value="">📊 Tous</option>
                    <option value="disponible">✅ Disponible</option>
                    <option value="rupture">⚠️ Rupture</option>
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
            <i class="bx bx-info-circle"></i> <span id="resultCount">0</span> produit(s) trouvé(s)
        </div>
        
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th>Image</th>
                        <th>Nom</th>
                        <th>Catégorie</th>
                        <th>Prix</th>
                        <th>Statut</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody id="productsTableBody">
                    @forelse($products as $product)
                    <tr>
                        <td>
                            @if($product->image)
                                <img src="{{ $product->image_url }}" 
                                     alt="{{ $product->nom }}" 
                                     style="width: 50px; height: 50px; object-fit: cover; border-radius: 8px;"
                                     onerror="this.onerror=null; this.style.display='none'; this.nextElementSibling.style.display='flex';">
                                <div style="width: 50px; height: 50px; background: #e9ecef; border-radius: 8px; display: none; align-items: center; justify-content: center;">
                                    <i class="bx bx-image" style="font-size: 24px; color: #adb5bd;"></i>
                                </div>
                            @else
                                <div style="width: 50px; height: 50px; background: #e9ecef; border-radius: 8px; display: flex; align-items: center; justify-content: center;">
                                    <i class="bx bx-image" style="font-size: 24px; color: #adb5bd;"></i>
                                </div>
                            @endif
                        </td>
                        <td><strong>{{ $product->nom }}</strong></td>
                        <td><span class="badge bg-secondary">{{ $product->categorie->nom ?? 'N/A' }}</span></td>
                        <td><strong>{{ number_format($product->prix, 0, ',', ' ') }} FCFA</strong></td>
                        <td>
                            @if($product->actif && $product->disponible)
                                <span class="badge bg-success">Disponible</span>
                            @elseif($product->actif && !$product->disponible)
                                <span class="badge bg-warning">Rupture</span>
                            @else
                                <span class="badge bg-secondary">Inactif</span>
                            @endif
                        </td>
                        <td>
                            <a href="{{ route('menu.products.edit', $product) }}" class="btn btn-sm btn-warning"><i class="bx bx-edit"></i></a>
                            <form action="{{ route('menu.products.destroy', $product) }}" method="POST" style="display:inline;" onsubmit="return confirm('Supprimer ce produit ?')">
                                @csrf @method('DELETE')
                                <button type="submit" class="btn btn-sm btn-danger"><i class="bx bx-trash"></i></button>
                            </form>
                        </td>
                    </tr>
                    @empty
                    <tr class="no-results">
                        <td colspan="6" class="text-center text-muted">Aucun produit trouvé</td>
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
    const filterCategorie = document.getElementById('filterCategorie');
    const filterStatut = document.getElementById('filterStatut');
    const resetBtn = document.getElementById('resetFilters');
    const tableBody = document.getElementById('productsTableBody');
    const searchResults = document.getElementById('searchResults');
    const resultCount = document.getElementById('resultCount');
    const allRows = tableBody.querySelectorAll('tr:not(.no-results)');
    
    function filterProducts() {
        const searchTerm = searchInput.value.toLowerCase();
        const categorieFilter = filterCategorie.value.toLowerCase();
        const statutFilter = filterStatut.value.toLowerCase();
        let visibleCount = 0;
        
        allRows.forEach(row => {
            const nom = row.querySelector('td:nth-child(2)').textContent.toLowerCase();
            const categorie = row.querySelector('td:nth-child(3)').textContent.toLowerCase();
            const statut = row.querySelector('td:nth-child(5)').textContent.toLowerCase();
            
            const matchSearch = nom.includes(searchTerm);
            const matchCategorie = !categorieFilter || categorie.includes(categorieFilter);
            const matchStatut = !statutFilter || statut.includes(statutFilter);
            
            if (matchSearch && matchCategorie && matchStatut) {
                row.style.display = '';
                visibleCount++;
            } else {
                row.style.display = 'none';
            }
        });
        
        if (searchTerm || categorieFilter || statutFilter) {
            searchResults.classList.remove('d-none');
            resultCount.textContent = visibleCount;
        } else {
            searchResults.classList.add('d-none');
        }
    }
    
    searchInput.addEventListener('keyup', filterProducts);
    filterCategorie.addEventListener('change', filterProducts);
    filterStatut.addEventListener('change', filterProducts);
    
    resetBtn.addEventListener('click', function() {
        searchInput.value = '';
        filterCategorie.value = '';
        filterStatut.value = '';
        searchResults.classList.add('d-none');
        allRows.forEach(row => row.style.display = '');
    });
});
</script>
@endpush
