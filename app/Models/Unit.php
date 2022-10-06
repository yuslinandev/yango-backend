<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Unit extends Model
{
    use HasFactory;

    // Estableciendo campo default id por uno personalizado: id_unit
    protected $primaryKey = 'id_unit';

    protected $fillable = [
        'name',
        'abbreviation',
        'state',
         'type',
        'user_creation'
    ];
}
