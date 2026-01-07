<?php

namespace App\Enums;

enum TableStatus: string
{
    case Libre = 'libre';
    case Occupee = 'occupee';
    case Reservee = 'reservee';
    case EnPaiement = 'en_paiement';
}

