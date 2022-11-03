<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Resources\Json\JsonResource;

class ProductResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return array|\Illuminate\Contracts\Support\Arrayable|\JsonSerializable
     */
    public function toArray($request)
    {
        return [

                        'id_product' => $this->id_product,
                        'internal_code'=> $this->internal_code,
                        'short_name'=> $this->short_name,
                        'long_name'=> $this->long_name,
                        'description'=> $this->description,
                        'id_brand'=> $this->id_brand,
                        'brand'=> $this->brand,
                        'id_unit'=> $this->id_unit,
                        'unit'=> $this->unit,
                        'ids_classification'=> $this->ids_classification,
                        'classification'=> $this->classification,
                        'id_categorization'=> $this->id_categorization,
                        'categorization'=> $this->categorization,
                        'product_type'=> $this->product_type,
                        'product_prices'=> $this->product_prices,
                        'id_image'=> $this->id_image,
                        'life_time'=> $this->life_time,
                        'id_unit_life_time'=> $this->id_unit_life_time,
                        'state'=> $this->state,
                        'user_creation'=> $this->user_creation,
                        'created_at'=> $this->created_at

        ];
    }
}
