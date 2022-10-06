<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Resources\Json\JsonResource;

class WarehouseResource extends JsonResource
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
            'id' => $this->id_warehouse,
            'short_name' => $this->short_name,
            'long_name' => $this->long_name,
            'description' => $this->description,
            'id_local' => $this->id_local,
            'id_responsible_employee' => $this->id_responsible_employee,
            'state' => $this->state
        ];
    }
}
