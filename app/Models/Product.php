<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

 public function brand()
    {
        return $this->belongsTo('App\Models\Brand', 'id_brand', 'id_brand');
    }

 public function unit()
    {
        return $this->belongsTo('App\Models\Unit', 'id_unit', 'id_unit');
    }

 public function classification()
    {
        return $this->belongsTo('App\Models\Classification', 'ids_classification', 'id_classification');
    }

 public function categorization()
    {
        return $this->belongsTo('App\Models\Categorization', 'id_categorization', 'id_categorization');
    }

     public function product_prices()
        {
            return $this->hasMany('App\Models\Product_prices', 'id_product','id_product');
        }



    protected $primaryKey = 'id_product';

    protected $fillable = [
        'internal_code',
        'short_name',
        'long_name',
        'description',
        'id_brand',
        'id_unit',
        'ids_classification',
        'id_categorization',
        'product_type',
        'id_image',
        'life_time',
        'id_unit_life_time',
        'state',
        'user_creation',
        'created_at'

    ];
}
