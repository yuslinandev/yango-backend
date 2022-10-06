<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Unit extends Model
{
    use HasFactory;


 public function products()

    {
        return $this->hasMany('App\Models\Product', 'id_unit', 'id_unit');
    }


    // Estableciendo campo default id por uno personalizado: id_unit
    protected $primaryKey = 'id_unit';

    protected $fillable = [
        'name',
        'abbreviation',
        'state',
         'type',
        'user_creation',
        'created_at'

    ];
}
