<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product_prices extends Model
{
    use HasFactory;


    protected $primaryKey = 'id_product_price';

    protected $fillable = [

        'id_product',
        'id_local',
        'price_type',
        'currency',
        'price_condition',
        'price',
        'validity_date_start',
        'validity_date_end',
        'state',
        'user_creation',
        'created_at'
    ];
}
