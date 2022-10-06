<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Warehouse;
use Illuminate\Http\Request;
use App\Http\Resources\V1\WarehouseCollection;
use Symfony\Component\HttpFoundation\Response;

class WarehouseController extends Controller
{
    /**
     * Display a listing custom of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function list(Request $request)
    {
        // Obtener data de la url, ej:
        http://127.0.0.1:8000/api/v1/warehouse_list?page=1&toShow=5&sortField=name&sort=DESC

        // Valores por defecto
        // page por default
        $size =  $request->input('size') ?? 10;
        $orderField = $request->input('orderField') ?? 'long_name';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'long_name';
        $search = $request->input('search') ?? '';

        if($search != ""){
            $warehouse = Warehouse::where( 'long_name', 'LIKE', '%' . $search . '%' )
                ->orwhere( 'description', 'LIKE', '%' . $search . '%' )
                ->where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }else{
            $warehouse = Warehouse::where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }

        return response()->json(
            new WarehouseCollection( $warehouse )
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
        // ver archivo de WarehouseResource
        return WarehouseResource::collection(Warehouse::latest()->paginate());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $this->validateWarehouse($request);

        //dd($request->all());

        // Aqui podemos personalizar los valore a guardar
         $state = $request->state;
                if (strval($state) ==  true ) {
                      $state = "A" ;
                } else
                {
                     $state = "E" ;
                }

        $warehouse = Warehouse::create([

          'short_name' => $request->short_name,
            'long_name' => $request->long_name,
            'description' => $request->description,
            'id_local' => $request->id_local,
            'id_responsible_employee' => $request->id_responsible_employee,
            'state' => $state,
             'user_creation' => auth()->user()->id
        ]);

        $warehouseInserted = Warehouse::find($warehouse->id_warehouse, ['id_warehouse AS id',

        'short_name',  'long_name', 'id_responsible_employee','description']);

        return response()->json([
            'message' => 'Warehouse Add',
            'data' => $warehouseInserted
        ], Response::HTTP_OK);
    }

    public function validateWarehouse(Request $request)
    {
        return $request->validate([
            'short_name' => 'required'
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Warehouse  $warehouse
     * @return \Illuminate\Http\Response
     */
    public function show(Warehouse $warehouse)
    {
        return new WarehouseResource($warehouse);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Warehouse  $warehouse
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $id = $request->id;

        $this->validateWarehouse($request);

        //dd($request->all());

        // $warehouse->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        // Aqui podemos personalizar los valore a guardar
         $state = $request->state;
                if (strval($state) ==  true ) {
                      $state = "A" ;
                } else
                {
                     $state = "E" ;
                }

        $warehouse = Warehouse::findOrFail($id)->update([

            'short_name' => $request->short_name,
            'long_name' => $request->long_name,
            'description' => $request->description,
            'id_local' => $request->id_local,
            'id_responsible_employee' => $request->id_responsible_employee,
            'state' => $state,
             'user_creation' => auth()->user()->id
        ]);

        $warehouseUpdated = Warehouse::find($id,['id_warehouse AS id','short_name',  'long_name', 'id_responsible_employee','description']);

        return response()->json([
            'message' => 'Warehouse Update',
            'data' => $warehouseUpdated
        ], Response::HTTP_OK);

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Warehouse  $warehouse
     * @return \Illuminate\Http\Response
     */
    public function destroy(Warehouse $warehouse)
    {
        $warehouse->delete();

        return response()->json([
            'message' => 'Warehouse Destroyed'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }

    /**
     * Logical delete register
     *
     */
    public function delete($id)
    {
        Warehouse::findOrFail($id)->update([
            'state' => "E"
        ]);

        return response()->json([
            'message' => 'Warehouse Deleted',
            'data' => 'true'
        ], Response::HTTP_ACCEPTED);
    }
}
