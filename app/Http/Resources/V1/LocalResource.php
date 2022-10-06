<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Resources\Json\JsonResource;

class LocalResource extends JsonResource
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
                'id' => $this->id_local,
                'internal_code'=> $this->internal_code,
                'short_name'=> $this->short_name,
                'long_name'=> $this->long_name,
                'description'=> $this->description,
                'address'=> $this->address,
                'id_ubigeo'=> $this->id_ubigeo,
                'type' => $this->type,
                'id_responsible_employee'=> $this->id_responsible_employee,
                'manage_warehouse'=> $this->manage_warehouse,
                'state' => $this->state

        ];
    }
}
