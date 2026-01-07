@extends('layouts.app')
@section('title', 'Payer Commande')
@section('content')
<div class="row">
    <div class="col-md-8">
        <div class="card">
            <div class="card-header">
                <h5 class="mb-0">💳 Paiement - Commande #{{ $commande->id }}</h5>
            </div>
            <div class="card-body">
                @if ($errors->any())
                    <div class="alert alert-danger">
                        <ul class="mb-0">
                            @foreach ($errors->all() as $error)
                                <li>{{ $error }}</li>
                            @endforeach
                        </ul>
                    </div>
                @endif
                
                <form action="{{ route('caisse.traiter', $commande) }}" method="POST" id="paiementForm">
                    @csrf
                    
                    <div class="mb-3">
                        <label class="form-label"><strong>Moyen de Paiement *</strong></label>
                        <select name="moyen_paiement" id="moyenPaiement" class="form-select" required onchange="togglePaymentFields()">
                            <option value="">Sélectionner...</option>
                            @foreach($moyensPaiement as $moyen)
                                <option value="{{ $moyen->value }}" {{ old('moyen_paiement') == $moyen->value ? 'selected' : '' }}>
                                    @switch($moyen->value)
                                        @case('especes') 💵 Espèces @break
                                        @case('wave') 📱 Wave @break
                                        @case('orange_money') 📱 Orange Money @break
                                        @case('carte_bancaire') 💳 Carte Bancaire @break
                                    @endswitch
                                </option>
                            @endforeach
                        </select>
                    </div>
                    
                    <div id="especesFields" style="display: none;">
                        <div class="mb-3">
                            <label class="form-label"><strong>Montant Reçu (FCFA) *</strong></label>
                            <input type="number" name="montant_recu" id="montantRecu" class="form-control" 
                                   value="{{ old('montant_recu', $commande->montant_total) }}" 
                                   min="{{ $commande->montant_total }}" 
                                   step="1"
                                   onkeyup="calculateChange()">
                        </div>
                        
                        <div class="mb-3">
                            <label class="form-label"><strong>Monnaie à Rendre</strong></label>
                            <input type="text" id="monnaieRendue" class="form-control" readonly 
                                   style="font-size: 1.5rem; font-weight: bold; color: #28a745;">
                        </div>
                    </div>
                    
                    <div id="referenceFields" style="display: none;">
                        <div class="mb-3">
                            <label class="form-label"><strong>Référence de Transaction *</strong></label>
                            <input type="text" name="reference_transaction" class="form-control" 
                                   value="{{ old('reference_transaction') }}" 
                                   placeholder="Ex: WV123456789 ou OM987654321">
                            <small class="text-muted">Numéro de référence de la transaction mobile money/carte</small>
                        </div>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label">Notes</label>
                        <textarea name="notes" class="form-control" rows="2">{{ old('notes') }}</textarea>
                    </div>
                    
                    <hr>
                    
                    <div class="d-flex justify-content-between">
                        <a href="{{ route('caisse.index') }}" class="btn btn-secondary">
                            <i class="bx bx-arrow-back"></i> Retour
                        </a>
                        <button type="submit" class="btn btn-success btn-lg">
                            <i class="bx bx-check"></i> Valider le Paiement
                        </button>
                    </div>
                </form>
            </div>
        </div>
    </div>
    
    <div class="col-md-4">
        <div class="card bg-light">
            <div class="card-header">
                <h6 class="mb-0">Résumé de la Commande</h6>
            </div>
            <div class="card-body">
                <div class="mb-3">
                    <strong>Table:</strong> {{ $commande->table->numero }}
                </div>
                
                <div class="mb-3">
                    <strong>Articles:</strong>
                    <ul class="small">
                        @foreach($commande->produits as $produit)
                            <li>{{ $produit->nom }} x{{ $produit->pivot->quantite }} 
                                = {{ number_format($produit->pivot->quantite * $produit->pivot->prix_unitaire, 0, ',', ' ') }} FCFA
                            </li>
                        @endforeach
                    </ul>
                </div>
                
                <hr>
                
                <div class="text-center">
                    <p class="text-muted mb-1">MONTANT TOTAL</p>
                    <h2 class="text-success mb-0">{{ number_format($commande->montant_total, 0, ',', ' ') }} FCFA</h2>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
function togglePaymentFields() {
    const moyenPaiement = document.getElementById('moyenPaiement').value;
    const especesFields = document.getElementById('especesFields');
    const referenceFields = document.getElementById('referenceFields');
    const montantRecuInput = document.getElementById('montantRecu');
    
    if (moyenPaiement === 'especes') {
        especesFields.style.display = 'block';
        referenceFields.style.display = 'none';
        montantRecuInput.required = true;
        calculateChange();
    } else if (moyenPaiement === 'wave' || moyenPaiement === 'orange_money' || moyenPaiement === 'carte_bancaire') {
        especesFields.style.display = 'none';
        referenceFields.style.display = 'block';
        montantRecuInput.required = false;
    } else {
        especesFields.style.display = 'none';
        referenceFields.style.display = 'none';
        montantRecuInput.required = false;
    }
}

function calculateChange() {
    const montantTotal = {{ $commande->montant_total }};
    const montantRecu = parseFloat(document.getElementById('montantRecu').value) || 0;
    const monnaie = montantRecu - montantTotal;
    
    if (monnaie >= 0) {
        document.getElementById('monnaieRendue').value = new Intl.NumberFormat('fr-FR').format(monnaie) + ' FCFA';
        document.getElementById('monnaieRendue').style.color = '#28a745';
    } else {
        document.getElementById('monnaieRendue').value = 'INSUFFISANT : ' + new Intl.NumberFormat('fr-FR').format(Math.abs(monnaie)) + ' FCFA';
        document.getElementById('monnaieRendue').style.color = '#dc3545';
    }
}

// Initialize on load
document.addEventListener('DOMContentLoaded', function() {
    togglePaymentFields();
});
</script>
@endsection

