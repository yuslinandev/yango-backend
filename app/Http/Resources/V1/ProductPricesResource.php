<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Resources\Json\JsonResource;

class ProductPricesResource extends JsonResource
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
            'id_product_price'=> $this->id_product_price,
            'id_product' => $this->id_product,
            'id_local' => $this->id_local,
            'price_type' => $this->price_type,
            'currency' => $this->currency,
            'price_condition' => $this->price_condition,
            'price' => $this->price,
            'validity_date_start' => $this->validity_date_start,
            'validity_date_end' => $this->validity_date_end,
            'state' => $this->state,
            'user_creation' => $this->user_creation,
            'created_at'  => $this->created_at,
        ];
    }
}
