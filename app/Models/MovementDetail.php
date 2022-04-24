<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class MovementDetail extends Model
{
    use HasFactory;

    protected $primaryKey = 'id_movement_detail';

    protected $fillable = [
        'id_movement',
        'id_product',
        'id_unit',
        'quantity',
        'value',
        'user_creation'
    ];
}
