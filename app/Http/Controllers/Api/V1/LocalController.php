<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Local;
use Illuminate\Http\Request;
use App\Http\Resources\V1\LocalCollection;
use Symfony\Component\HttpFoundation\Response;

class LocalController extends Controller
{
    /**
     * Display a listing custom of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function list(Request $request)
    {
        // Obtener data de la url, ej:
        http://127.0.0.1:8000/api/v1/local_list?page=1&toShow=5&sortField=name&sort=DESC

        // Valores por defecto
        // page por default
        $size =  $request->input('size') ?? 10;
        $orderField = $request->input('orderField') ?? 'long_name';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'long_name';
        $search = $request->input('search') ?? '';

        if($search != ""){
            $local = Local::where( 'long_name', 'LIKE', '%' . $search . '%' )
                ->orwhere( 'type', 'LIKE', '%' . $search . '%' )
                ->where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }else{
            $local = Local::where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }

        return response()->json(
            new LocalCollection( $local )
        , Response::HTTP_OK);

    }

        public function listAll()
            {
                    $local = Local::where('state', '<>', 'E')->get();


                return response()->json(
                    $local
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
        // ver archivo de LocalResource
        return LocalResource::collection(Local::latest()->paginate());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $this->validateLocal($request);

        //dd($request->all());

        $local = Local::create([

        'internal_code'=> $request->internal_code,
        'short_name'=> $request->short_name,
        'long_name'=> $request->long_name,
        'description'=> $request->description,
        'address'=> $request->address,
        'id_ubigeo'=> $request->id_ubigeo,
        'type' => $request->type,
        'id_responsible_employee'=> $request->id_responsible_employee,
        'manage_warehouse'=> $request->manage_warehouse,
        'state' => $request->state,
        'user_creation' => auth()->user()->id
        ]);

        $localInserted = Local::find($local->id_local, ['id_local AS id','short_name',  'type', 'abbreviation','state']);

        return response()->json([
            'message' => 'Local Add',
            'data' => $localInserted
        ], Response::HTTP_OK);
    }

    public function validateLocal(Request $request)
    {
        return $request->validate([
            'long_name' => 'required'
        ]);
        return $request->validate([
            'short_name' => 'required'
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Local  $local
     * @return \Illuminate\Http\Response
     */
    public function show(Local $local)
    {
        return new LocalResource($local);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Local  $local
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $id = $request->id;

        $this->validateLocal($request);

        //dd($request->all());

        // $local->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        // Aqui podemos personalizar los valore a guardar
         $state = $request->state;
                if (strval($state) ==  true ) {
                      $state = "A" ;
                } else
                {
                     $state = "I" ;
                }

        $local = Local::findOrFail($id)->update([

                    'internal_code'=> $request->internal_code,
                    'short_name'=> $request->short_name,
                    'long_name'=> $request->long_name,
                    'description'=> $request->description,
                    'address'=> $request->address,
                    'id_ubigeo'=> $request->id_ubigeo,
                    'type' => $request->type,
                    'id_responsible_employee'=> $request->id_responsible_employee,
                    'manage_warehouse'=> $request->manage_warehouse,
                    'state' => $state,
                    'user_edit' => auth()->user()->id,
        ]);

        $localUpdated = Local::find($id, ['id_local AS id','long_name', 'type','state']);

        return response()->json([
            'message' => 'Local Update',
            'data' => $localUpdated
        ], Response::HTTP_OK);

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Local  $local
     * @return \Illuminate\Http\Response
     */
    public function destroy(Local $local)
    {
        $local->delete();

        return response()->json([
            'message' => 'Local Destroyed'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }

    /**
     * Logical delete register
     *
     */
    public function delete($id)
    {
        Local::findOrFail($id)->update([
            'state' => "E"
        ]);

        return response()->json([
            'message' => 'Local Deleted',
            'data' => 'true'
        ], Response::HTTP_ACCEPTED);
    }
}
