<?php

namespace App\Enums;

enum StatutPaiement: string
{
    case EnAttente = 'en_attente';
    case Valide = 'valide';
    case Echoue = 'echoue';
    case Annule = 'annule';
}

