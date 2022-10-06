<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Employee_areas extends Model
{
    use HasFactory;

    protected $primaryKey = 'id_employee_area';

    protected $fillable = [
        'name',
        'description',
        'state',
        'user_creation',
        'created_at'

    ];
}
