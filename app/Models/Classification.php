<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Classification extends Model
{
    use HasFactory;

    // Estableciendo campo default id por uno personalizado: id_classification
    protected $primaryKey = 'id_classification';

    protected $fillable = [
        'name',
        'description',
        'state',
        'parent_id',
        'user_creation'
    ];
}
