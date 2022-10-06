<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Resources\Json\JsonResource;

class ProductStocksResource extends JsonResource
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
         'id_local'=> $this->id_local,
         'id_warehouse'=> $this->id_warehouse,
         'date'=> $this->date,
         'stock'=> $this->stock,

        ];
    }
}
