<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Employee_areas;
use Illuminate\Http\Request;
use App\Http\Resources\V1\AreaCollection; // llamar al recurso
use Symfony\Component\HttpFoundation\Response; // lista de codigos de estado

class AreaController extends Controller
{
    /**
     * Display a listing custom of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function list(Request $request)
    {
        // Obtener data de la url, ej:
        http://127.0.0.1:8000/api/v1/area_list?page=1&toShow=5&sortField=name&sort=DESC

        // Valores por defecto
        // page por default
        $size =  $request->input('size') ?? 10;
        $orderField = $request->input('orderField') ?? 'name';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'name';
        $search = $request->input('search') ?? '';

        if($search != ""){
            $area = Employee_areas::where( 'name', 'LIKE', '%' . $search . '%' )
                ->orwhere( 'description', 'LIKE', '%' . $search . '%' )
                ->where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }else{
            $area = Employee_areas::where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }

        return response()->json(
            new AreaCollection( $area )
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
        // ver archivo de AreaResource
        return AreaResource::collection(Employee_areas::latest()->paginate());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $this->validateArea($request);

        //dd($request->all());

        $area = Employee_areas::create([
            'name' => $request->name,
            'description' => $request -> description,
            'state' => $request->state,
            'user_creation' => auth()->user()->id
        ]);

        $areaInserted = Employee_areas::find($area->id_area, ['id_employee_area AS id','name', 'description','state']);

        return response()->json([
            'message' => 'Area Add',
            'data' => $areaInserted
        ], Response::HTTP_OK);
    }

    public function validateArea(Request $request)
    {
        return $request->validate([
            'name' => 'required'
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Area  $area
     * @return \Illuminate\Http\Response
     */
    public function show(Area $area)
    {
        return new AreaResource($area);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Area  $area
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $id = $request->id;

        $this->validateArea($request);

        //dd($request->all());

        // $area->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        // Aqui podemos personalizar los valore a guardar
         $state = $request->state;
                if (strval($state) ==  true ) {
                      $state = "A" ;
                } else
                {
                     $state = "E" ;
                }

        $area = Employee_areas::findOrFail($id)->update([
            'name' => $request->name,
            'description' => $request->description,
            'user_edit' => auth()->user()->id,
            'state' => $state
        ]);

        $areaUpdated = Employee_areas::find($id, ['id_employee_area AS id','name', 'description','state']);

        return response()->json([
            'message' => 'Area Update',
            'data' => $areaUpdated
        ], Response::HTTP_OK);

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Area  $area
     * @return \Illuminate\Http\Response
     */
    public function destroy(Area $area)
    {
        $area->delete();

        return response()->json([
            'message' => 'Area Destroyed'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }

    /**
     * Logical delete register
     *
     */
    public function delete($id)
    {
        Employee_areas::findOrFail($id)->update([
            'state' => "E"
        ]);

        return response()->json([
            'message' => 'Area Deleted',
            'data' => 'true'
        ], Response::HTTP_ACCEPTED);
    }
}
