<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Brand extends Model
{
    use HasFactory;

    // Estableciendo campo default id por uno personalizado: id_brand
    protected $primaryKey = 'id_brand';

    protected $fillable = [
        'name',
        'description',
        'state',
        'user_creation'
    ];
}
