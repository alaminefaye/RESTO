@extends('layouts.app')
@section('title', 'Facture ' . $facture->numero_facture)
@section('content')
<div class="card">
    <div class="card-header d-flex justify-content-between align-items-center">
        <h5 class="mb-0">📄 Facture {{ $facture->numero_facture }}</h5>
        <div>
            @if($facture->chemin_pdf)
                <a href="{{ route('caisse.facture.telecharger', $facture) }}" class="btn btn-primary" target="_blank">
                    <i class="bx bx-download"></i> Télécharger PDF
                </a>
            @endif
            <a href="{{ route('caisse.index') }}" class="btn btn-secondary">
                <i class="bx bx-arrow-back"></i> Retour à la Caisse
            </a>
        </div>
    </div>
    <div class="card-body">
        <!-- En-tête de la facture -->
        <div class="row mb-4">
            <div class="col-md-6">
                <h4>{{ config('app.name', 'Mon Restaurant') }}</h4>
                <p class="mb-0">
                    Adresse du restaurant<br>
                    Téléphone du restaurant<br>
                    Email du restaurant
                </p>
            </div>
            <div class="col-md-6 text-end">
                <h5>FACTURE</h5>
                <p class="mb-0">
                    <strong>N°:</strong> {{ $facture->numero_facture }}<br>
                    <strong>Date:</strong> {{ $facture->created_at->format('d/m/Y H:i') }}<br>
                    <strong>Commande:</strong> #{{ $facture->commande->id }}
                </p>
            </div>
        </div>
        
        <!-- Informations client et table -->
        <div class="row mb-4">
            <div class="col-md-6">
                <h6>Informations</h6>
                <p class="mb-0">
                    <strong>Table:</strong> {{ $facture->commande->table->numero }}<br>
                    <strong>Serveur:</strong> {{ $facture->commande->user->name ?? 'N/A' }}<br>
                    <strong>Caissier:</strong> {{ $facture->paiement->user->name ?? 'N/A' }}
                </p>
            </div>
            <div class="col-md-6">
                <h6>Paiement</h6>
                <p class="mb-0">
                    <strong>Moyen:</strong> 
                    @switch($facture->paiement->moyen_paiement->value)
                        @case('especes') 💵 Espèces @break
                        @case('wave') 📱 Wave @break
                        @case('orange_money') 📱 Orange Money @break
                        @case('carte_bancaire') 💳 Carte Bancaire @break
                    @endswitch
                    <br>
                    <strong>Statut:</strong> 
                    <span class="badge bg-{{ $facture->paiement->statut->value === 'valide' ? 'success' : 'warning' }}">
                        {{ ucfirst($facture->paiement->statut->value) }}
                    </span>
                    @if($facture->paiement->reference_transaction)
                        <br><strong>Réf:</strong> {{ $facture->paiement->reference_transaction }}
                    @endif
                </p>
            </div>
        </div>
        
        <hr>
        
        <!-- Détails des articles -->
        <h6 class="mb-3">Détails de la Commande</h6>
        <table class="table table-bordered">
            <thead class="table-light">
                <tr>
                    <th>Article</th>
                    <th class="text-center">Quantité</th>
                    <th class="text-end">Prix Unitaire</th>
                    <th class="text-end">Sous-total</th>
                </tr>
            </thead>
            <tbody>
                @foreach($facture->commande->produits as $produit)
                <tr>
                    <td>
                        <strong>{{ $produit->nom }}</strong><br>
                        <small class="text-muted">{{ $produit->categorie->nom ?? '' }}</small>
                        @if($produit->pivot->notes)
                            <br><small class="text-info">Note: {{ $produit->pivot->notes }}</small>
                        @endif
                    </td>
                    <td class="text-center">{{ $produit->pivot->quantite }}</td>
                    <td class="text-end">{{ number_format($produit->pivot->prix_unitaire, 0, ',', ' ') }} FCFA</td>
                    <td class="text-end">{{ number_format($produit->pivot->quantite * $produit->pivot->prix_unitaire, 0, ',', ' ') }} FCFA</td>
                </tr>
                @endforeach
            </tbody>
            <tfoot>
                <tr>
                    <td colspan="3" class="text-end"><strong>Sous-total:</strong></td>
                    <td class="text-end"><strong>{{ number_format($facture->commande->montant_total, 0, ',', ' ') }} FCFA</strong></td>
                </tr>
                <tr>
                    <td colspan="3" class="text-end"><strong>Taxe (10%):</strong></td>
                    <td class="text-end"><strong>{{ number_format($facture->montant_taxe, 0, ',', ' ') }} FCFA</strong></td>
                </tr>
                <tr class="table-success">
                    <td colspan="3" class="text-end"><strong>TOTAL:</strong></td>
                    <td class="text-end"><h4 class="mb-0">{{ number_format($facture->montant_total, 0, ',', ' ') }} FCFA</h4></td>
                </tr>
                
                @if($facture->paiement->moyen_paiement->value === 'especes')
                <tr>
                    <td colspan="3" class="text-end">Montant reçu:</td>
                    <td class="text-end">{{ number_format($facture->paiement->montant_recu, 0, ',', ' ') }} FCFA</td>
                </tr>
                <tr>
                    <td colspan="3" class="text-end">Monnaie rendue:</td>
                    <td class="text-end"><strong>{{ number_format($facture->paiement->monnaie_rendue, 0, ',', ' ') }} FCFA</strong></td>
                </tr>
                @endif
            </tfoot>
        </table>
        
        <div class="text-center mt-4">
            <p class="text-muted mb-0">Merci de votre visite !</p>
            <p class="text-muted small">Document généré le {{ $facture->created_at->format('d/m/Y à H:i') }}</p>
        </div>
    </div>
</div>

<div class="text-center mt-3">
    <button onclick="window.print()" class="btn btn-outline-primary">
        <i class="bx bx-printer"></i> Imprimer
    </button>
    <a href="{{ route('caisse.index') }}" class="btn btn-success">
        <i class="bx bx-check"></i> Nouvelle Transaction
    </a>
</div>

<style>
@media print {
    .card-header, .btn, nav, aside, footer {
        display: none !important;
    }
    .card {
        border: none !important;
        box-shadow: none !important;
    }
}
</style>
@endsection

