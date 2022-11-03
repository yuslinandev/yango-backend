<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Categorization extends Model
{
    use HasFactory;

 public function products()

    {
        return $this->hasMany('App\Models\Product', 'id_categorization', 'id_categorization');
    }

    // Estableciendo campo default id por uno personalizado: id_unit
    protected $primaryKey = 'id_categorization';

    protected $fillable = [
        'name',
        'description',
        'state',
        'user_creation'
    ];
}
