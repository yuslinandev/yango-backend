<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Warehouse extends Model
{
    use HasFactory;

    protected $primaryKey = 'id_warehouse';

    protected $fillable = [
        'short_name',
        'long_name',
        'description',
        'id_local',
        'id_responsible_employee',
        'state',
        'user_creation',
        'created_at'

    ];
}
