<?php

namespace App\Enums;

enum OrderStatus: string
{
    case Attente = 'attente';
    case Preparation = 'preparation';
    case Servie = 'servie';
    case Terminee = 'terminee';
    case Annulee = 'annulee';
}
