<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Resources\Json\JsonResource;

class ConfigsResource extends JsonResource
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
                    'id_config' => $this->id_config,
                     'table' => $this->table,
                    'code' => $this->code,
                    'field' => $this->field,
                    'alp_num_value' => $this->alp_num_value,
                    'num_value' => $this->num_value,
                    'state' => $this->state,
                    'validity_date_start' => $this->validity_date_start,
                    'validity_date_end' => $this->validity_date_end,
                    'order_number' => $this->order_number
        ];
    }
}
