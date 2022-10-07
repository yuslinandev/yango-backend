<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Local extends Model
{
    use HasFactory;

    protected $primaryKey = 'id_local';

    protected $fillable = [
        'internal_code',
        'short_name',
        'long_name',
        'description',
        'address',
        'id_ubigeo',
        'type',
        'id_responsible_employee',
        'manage_warehouse',
        'state',
        'user_creation',
        'created_at'

    ];
}
