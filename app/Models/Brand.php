<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Brand extends Model
{
    use HasFactory;

 public function products()

    {
        return $this->hasMany('App\Models\Product', 'id_brand', 'id_brand');
    }

    // Estableciendo campo default id por uno personalizado: id_brand
    protected $primaryKey = 'id_brand';

    protected $fillable = [
        'name',
        'description',
        'state',
        'user_creation'
    ];
}
