<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Configs extends Model
{
    use HasFactory;


    protected $primaryKey = 'id_config';

    protected $fillable = [
        'table',
        'code',
        'field',
        'alp_num_value',
        'num_value',
        'state',
        'validity_date_start',
        'validity_date_end',
        'order_number'
    ];
}
