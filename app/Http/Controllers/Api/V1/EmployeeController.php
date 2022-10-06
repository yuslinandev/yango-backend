<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Employees;
use Illuminate\Http\Request;
use App\Http\Resources\V1\EmployeeCollection;
use Symfony\Component\HttpFoundation\Response;

class EmployeeController extends Controller
{
    /**
     * Display a listing custom of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function list(Request $request)
    {
        // Obtener data de la url, ej:
        http://127.0.0.1:8000/api/v1/employee_list?page=1&toShow=5&sortField=name&sort=DESC

        // Valores por defecto
        // page por default
        $size =  $request->input('size') ?? 10;
        $orderField = $request->input('orderField') ?? 'names';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'names';
        $search = $request->input('search') ?? '';

        if($search != ""){
            $employee = Employees::where( 'names', 'LIKE', '%' . $search . '%' )
                ->orwhere( 'last_name_1', 'LIKE', '%' . $search . '%' )
                ->where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }else{
            $employee = Employees::where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }

        return response()->json(
            new EmployeeCollection( $employee )
        , Response::HTTP_OK);

    }
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        // Para cambiar los datos a mostrar en la coleccion,
        // ver archivo de EmployeeResource
        return EmployeeResource::collection(Employees::latest()->paginate());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $this->validateEmployee($request);

        //dd($request->all());

        $employee = Employees::create([
            'id_employee' => $this->id_employee,
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
             'state' => $this->state,
            'user_creation' => auth()->user()->id

        ]);




        $employeeInserted = Employees::find($employee->id_employee, ['id_employee AS id',            'document_number',
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
                                                                                                    'created_at']);

        return response()->json([
            'message' => 'Employee Add',
            'data' => $employeeInserted
        ], Response::HTTP_OK);
    }

    public function validateEmployee(Request $request)
    {
        return $request->validate([
            'names' => 'required'
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Employee  $employee
     * @return \Illuminate\Http\Response
     */
    public function show(Employee $employee)
    {
        return new EmployeeResource($employee);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Employee  $employee
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $id = $request->id;

        $this->validateEmployee($request);

        //dd($request->all());

        // $employee->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        // Aqui podemos personalizar los valore a guardar
         $state = $request->state;
                if (strval($state) ==  true ) {
                      $state = "A" ;
                } else
                {
                     $state = "E" ;
                }

        $employee = Employees::findOrFail($id)->update([
            'document_number' => $request->document_number,
                'document_type'=> $request->document_type,
                        'names'=> $request->names,
                         'last_name_1'=> $request->last_name_1,
                         'last_name_2'=> $request->last_name_2,
                         'address'=> $request->address,
                         'id_ubigeo'=> $request->id_ubigeo,
                         'id_employee_area'=> $request->id_employee_area,
                         'id_employee_job'=> $request->id_employee_job,
                         'id_warehouse_assigned' => $request->id_warehouse_assigned,
                         'id_local_assigned'=> $request->id_local_assigned,
            'user_edit' => auth()->user()->id,
            'user_creation' => auth()->user()->id,
            'state' => $state

        ]);

        $employeeUpdated = Employees::find($id, ['id_employee AS id', 'document_number', 'document_type',
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
                                                'created_at']);

        return response()->json([
            'message' => 'Employee Update',
            'data' => $employeeUpdated
        ], Response::HTTP_OK);

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Employee  $employee
     * @return \Illuminate\Http\Response
     */
    public function destroy(Employee $employee)
    {
        $employee->delete();

        return response()->json([
            'message' => 'Employee Destroyed'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }

    /**
     * Logical delete register
     *
     */
    public function delete($id)
    {
        Employees::findOrFail($id)->update([
            'state' => "E"
        ]);

        return response()->json([
            'message' => 'Employee Deleted',
            'data' => 'true'
        ], Response::HTTP_ACCEPTED);
    }
}
