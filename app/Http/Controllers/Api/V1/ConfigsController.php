<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Configs;
use Illuminate\Http\Request;
use App\Http\Resources\V1\ConfigsCollection; // llamar al recurso
use Symfony\Component\HttpFoundation\Response; // lista de codigos de estado

class ConfigsController extends Controller
{
    /**
     * Display a listing custom of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function list(Request $request)
    {

        // Valores por defecto
        // page por default
        $size =  $request->input('size') ?? 10;
        $orderField = $request->input('orderField') ?? 'table';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'table';
        $search = $request->input('search') ?? '';

        if($search != ""){
            $configs = Configs::where( 'table', 'LIKE', '%' . $search . '%' )
                ->orwhere( 'field', 'LIKE', '%' . $search . '%' )
                ->where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }else{
            $configs = Configs::where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }

        return response()->json(
            new ConfigsCollection( $configs )
        , Response::HTTP_OK);

    }

        public function listAllWithFilters(Request $request)
            {
            $table =  $request->input('table');
            $code =  $request->input('code');

                    $configs = Configs::where('table', 'LIKE', '%' . $table . '%' )
                    ->orwhere('code', 'LIKE', '%' . $code . '%' )->get();


                return response()->json(
                    $configs
                , Response::HTTP_OK);

            }

    public function listAll()
        {
                $configs = Configs::where('state', '<>', 'E')->get();


            return response()->json(
                $configs
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
        // ver archivo de ConfigsResource
        return ConfigsResource::collection(Configs::latest()->paginate());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $this->validateConfigs($request);

        //dd($request->all());

        $configs = Configs::create([

            'id_config' => $request->id_config,
             'table' => $request->table,
            'code' => $request->code,
            'field' => $request->field,
            'alp_num_value' => $request->alp_num_value,
            'num_value' => $request->num_value,
            'state' => $request->state,
            'validity_date_start' => $request->validity_date_start,
            'validity_date_end' => $request->validity_date_end,
            'order_number' => $request->order_number
        ]);

        $configsInserted = Configs::find($configs->id_config, ['id_config AS id',        'table',
                                                                                       'code',
                                                                                       'field',
                                                                                       'alp_num_value',
                                                                                       'num_value',
                                                                                       'state',
                                                                                       'validity_date_start',
                                                                                       'validity_date_end',
                                                                                       'order_number']);

        return response()->json([
            'message' => 'Configs Add',
            'data' => $configsInserted
        ], Response::HTTP_OK);
    }

    public function validateConfigs(Request $request)
    {
        return $request->validate([
            'table' => 'required'
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Configs  $configs
     * @return \Illuminate\Http\Response
     */
    public function show(Configs $configs)
    {
        return new ConfigsResource($configs);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Configs  $configs
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $id = $request->id;

        $this->validateConfigs($request);

        //dd($request->all());
        // $configs->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        // Aqui podemos personalizar los valore a guardar
        $state = $request->state;
        if (strval($state) ==  true ) {
              $state = "A" ;
        } else
        {
             $state = "I" ;
        }
        $configs = Configs::findOrFail($id)->update([
            'id_config' => $request->id_config,
            'table' => $request->table,
           'code' => $request->code,
           'field' => $request->field,
           'alp_num_value' => $request->alp_num_value,
           'num_value' => $request->num_value,
           'state' => $state,
           'validity_date_start' => $request->validity_date_start,
           'validity_date_end' => $request->validity_date_end,
           'order_number' => $request->order_number
        ]);

        $configsUpdated = Configs::find($id, ['id_config AS id', 'table',
                                             'code',
                                             'field',
                                             'alp_num_value',
                                             'num_value',
                                             'state',
                                             'validity_date_start',
                                             'validity_date_end',
                                             'order_number']);

        return response()->json([
            'message' => 'Configs Update',
            'data' => $configsUpdated
        ], Response::HTTP_OK);

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Configs  $configs
     * @return \Illuminate\Http\Response
     */
    public function destroy(Configs $configs)
    {
        $configs->delete();

        return response()->json([
            'message' => 'Configs Destroyed'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }

    /**
     * Logical delete register
     *
     */
    public function delete($id)
    {
        Configs::findOrFail($id)->update([
            'state' => "E"
        ]);

        return response()->json([
            'message' => 'Configs Deleted',
            'data' => 'true'
        ], Response::HTTP_ACCEPTED);
    }
}
