<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Unit;
use Illuminate\Http\Request;
use App\Http\Resources\V1\UnitCollection; // llamar al recurso
use Symfony\Component\HttpFoundation\Response; // lista de codigos de estado

class UnitController extends Controller
{
    /**
     * Display a listing custom of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function list(Request $request)
    {
        // Obtener data de la url, ej:
        http://127.0.0.1:8000/api/v1/unit_list?page=1&toShow=5&sortField=name&sort=DESC

        // Valores por defecto
        // page por default
        $size =  $request->input('size') ?? 10;
        $orderField = $request->input('orderField') ?? 'name';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'name';
        $search = $request->input('search') ?? '';

        if($search != ""){
            $unit = Unit::where( 'name', 'LIKE', '%' . $search . '%' )
                ->orwhere( 'type', 'LIKE', '%' . $search . '%' )
                ->where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }else{
            $unit = Unit::where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }

        return response()->json(
            new UnitCollection( $unit )
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
        // ver archivo de UnitResource
        return UnitResource::collection(Unit::latest()->paginate());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $this->validateUnit($request);

        //dd($request->all());

        $unit = Unit::create([
            'name' => $request->name,
            'type' => $request->type,
            'abbreviation' => $request -> abbreviation,
            'user_creation' => auth()->user()->id
        ]);

        $unitInserted = Unit::find($unit->id_unit, ['id_unit AS id','name',  'type', 'abbreviation','state']);

        return response()->json([
            'message' => 'Unit Add',
            'data' => $unitInserted
        ], Response::HTTP_OK);
    }

    public function validateUnit(Request $request)
    {
        return $request->validate([
            'name' => 'required'
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Unit  $unit
     * @return \Illuminate\Http\Response
     */
    public function show(Unit $unit)
    {
        return new UnitResource($unit);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Unit  $unit
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $id = $request->id;

        $this->validateUnit($request);

        //dd($request->all());

        // $unit->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        // Aqui podemos personalizar los valore a guardar
         $state = $request->state;
                if (strval($state) ==  true ) {
                      $state = "A" ;
                } else
                {
                     $state = "E" ;
                }

        $unit = Unit::findOrFail($id)->update([
            'name' => $request->name,
            'type' => $request->type,
            'user_edit' => auth()->user()->id,
            'state' => $state
        ]);

        $unitUpdated = Unit::find($id, ['id_unit AS id','name', 'type','state']);

        return response()->json([
            'message' => 'Unit Update',
            'data' => $unitUpdated
        ], Response::HTTP_OK);

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Unit  $unit
     * @return \Illuminate\Http\Response
     */
    public function destroy(Unit $unit)
    {
        $unit->delete();

        return response()->json([
            'message' => 'Unit Destroyed'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }

    /**
     * Logical delete register
     *
     */
    public function delete($id)
    {
        Unit::findOrFail($id)->update([
            'state' => "E"
        ]);

        return response()->json([
            'message' => 'Unit Deleted',
            'data' => 'true'
        ], Response::HTTP_ACCEPTED);
    }
}
