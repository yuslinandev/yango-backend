<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Categorization extends Model
{
    use HasFactory;

    // Estableciendo campo default id por uno personalizado: id_unit
    protected $primaryKey = 'id_categorization';

    protected $fillable = [
        'name',
        'description',
        'state',
        'user_creation'
    ];
}
