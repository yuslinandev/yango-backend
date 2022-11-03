<?php

namespace App\Http\Resources\V1;

use Illuminate\Http\Resources\Json\JsonResource;

class EmployeeResource extends JsonResource
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
                    'id' => $this->id_employee,
                    'document_number' => $this->document_number,
                    'document_type'=> $this->document_type,
                    'names'=> $this->names,
                     'last_name_1'=> $this->last_name_1,
                     'last_name_2'=> $this->last_name_2,
                     'address'=> $this->address,
                     'id_ubigeo'=> $this->id_ubigeo,
                     'id_employee_area'=> $this->id_employee_area,
                     'id_employee_job'=> $this->id_employee_job,
                     'id_warehouse_assigned' => $this->id_warehouse_assigned,
                     'id_local_assigned'=> $this->id_local_assigned,
                     'state' => $this->state






        ];
    }
}
