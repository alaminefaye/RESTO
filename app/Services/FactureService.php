<?php

namespace App\Services;

use App\Models\Commande;
use App\Models\Paiement;
use App\Models\Facture;
use Illuminate\Support\Facades\Storage;
use Barryvdh\DomPDF\Facade\Pdf;

class FactureService
{
    /**
     * Génère une facture pour une commande et un paiement
     */
    public function genererFacture(Commande $commande, Paiement $paiement): Facture
    {
        // Générer le numéro de facture unique
        $numeroFacture = Facture::genererNumeroFacture();

        // Créer la facture
        $facture = Facture::create([
            'commande_id' => $commande->id,
            'paiement_id' => $paiement->id,
            'numero_facture' => $numeroFacture,
            'montant_total' => $commande->total_amount,
            'montant_taxe' => 0, // À calculer si TVA applicable
        ]);

        // Générer le PDF
        $pdfPath = $this->genererPDF($facture);
        $facture->fichier_pdf = $pdfPath;
        $facture->save();

        return $facture;
    }

    /**
     * Génère le fichier PDF de la facture
     */
    private function genererPDF(Facture $facture): string
    {
        // Charger la facture avec toutes ses relations
        $facture->load(['commande.table', 'commande.products', 'commande.user', 'paiement']);

        // Préparer les données pour le PDF
        $data = [
            'facture' => $facture,
            'commande' => $facture->commande,
            'table' => $facture->commande->table,
            'products' => $facture->commande->products,
            'paiement' => $facture->paiement,
            'restaurant' => [
                'nom' => config('app.name', 'Restaurant'),
                'adresse' => 'Dakar, Sénégal', // À configurer
                'telephone' => '+221 XX XXX XX XX', // À configurer
                'email' => 'contact@resto.sn', // À configurer
            ],
        ];

        // Générer le PDF avec une vue
        $pdf = Pdf::loadView('factures.template', $data);

        // Définir le chemin de sauvegarde
        $fileName = "facture-{$facture->numero_facture}.pdf";
        $path = "factures/{$fileName}";

        // Sauvegarder le PDF
        Storage::disk('public')->put($path, $pdf->output());

        return "public/{$path}";
    }

    /**
     * Télécharge une facture
     */
    public function telechargerFacture(Facture $facture): \Symfony\Component\HttpFoundation\BinaryFileResponse
    {
        $filePath = Storage::path($facture->fichier_pdf);
        
        return response()->download($filePath, "facture-{$facture->numero_facture}.pdf");
    }

    /**
     * Régénère le PDF d'une facture existante
     */
    public function regenererPDF(Facture $facture): Facture
    {
        // Supprimer l'ancien PDF si existe
        if ($facture->fichier_pdf && Storage::exists($facture->fichier_pdf)) {
            Storage::delete($facture->fichier_pdf);
        }

        // Générer un nouveau PDF
        $pdfPath = $this->genererPDF($facture);
        $facture->fichier_pdf = $pdfPath;
        $facture->save();

        return $facture;
    }
}

