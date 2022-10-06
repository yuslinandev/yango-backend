<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product_stocks extends Model
{
    use HasFactory;

    protected $primaryKey = ['id_product', 'id_local', 'id_warehouse'];
    public $incrementing = false;
    protected $fillable = [
        'date',
        'stock'
    ];
}
