<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Employees extends Model
{
    use HasFactory;


        protected $primaryKey = 'id_employee';

        protected $fillable = [
            'document_number',
            'document_type',
            'names',
             'last_name_1',
             'last_name_2',
             'address',
             'id_ubigeo',
             'id_employee_area',
             'id_employee_job',
             'id_warehouse_assigned',
             'id_local_assigned',
             'state',
            'user_creation',
            'created_at'

        ];

}
