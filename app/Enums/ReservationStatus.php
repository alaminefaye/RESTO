<?php

namespace App\Enums;

enum ReservationStatus: string
{
    case Attente = 'attente';
    case Confirmee = 'confirmee';
    case EnCours = 'en_cours';
    case Terminee = 'terminee';
    case Annulee = 'annulee';
}
