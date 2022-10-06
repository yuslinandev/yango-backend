<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Categorization;
use Illuminate\Http\Request;
use App\Http\Resources\V1\CategorizationCollection; // llamar al recurso
use Symfony\Component\HttpFoundation\Response; // lista de codigos de estado

class CategorizationController extends Controller
{
    /**
     * Display a listing custom of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function list(Request $request)
    {
        // Obtener data de la url, ej:
        http://127.0.0.1:8000/api/v1/categorization_list?page=1&toShow=5&sortField=name&sort=DESC

        // Valores por defecto
        // page por default
        $size =  $request->input('size') ?? 10;
        $orderField = $request->input('orderField') ?? 'name';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'name';
        $search = $request->input('search') ?? '';

        if($search != ""){
            $categorization = Categorization::where( 'name', 'LIKE', '%' . $search . '%' )
                ->orwhere( 'description', 'LIKE', '%' . $search . '%' )
                ->where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }else{
            $categorization = Categorization::where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }

        return response()->json(
            new CategorizationCollection( $categorization )
        , Response::HTTP_OK);

    }

    public function listAll()
        {
                $categorization = Categorization::where('state', '<>', 'E')->get();


            return response()->json(
                $categorization
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
        // ver archivo de CategorizationResource
        return CategorizationResource::collection(Categorization::latest()->paginate());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $this->validateCategorization($request);

        //dd($request->all());

        $categorization = Categorization::create([
            'name' => $request->name,
            'description' => $request->description,
            'state' => $request->state,
            'user_creation' => auth()->user()->id
        ]);

        $categorizationInserted = Categorization::find($categorization->id_categorization, ['id_categorization AS id','name', 'description','state']);

        return response()->json([
            'message' => 'Categorization Add',
            'data' => $categorizationInserted
        ], Response::HTTP_OK);
    }

    public function validateCategorization(Request $request)
    {
        return $request->validate([
            'name' => 'required'
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Categorization  $categorization
     * @return \Illuminate\Http\Response
     */
    public function show(Categorization $categorization)
    {
        return new CategorizationResource($categorization);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Categorization  $categorization
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $id = $request->id;

        $this->validateCategorization($request);

        //dd($request->all());

        // $categorization->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        // Aqui podemos personalizar los valore a guardar
                $state = $request->state;
                if (strval($state) ==  true ) {
                      $state = "A" ;
                } else
                {
                     $state = "E" ;
                }

        $categorization = Categorization::findOrFail($id)->update([
            'name' => $request->name,
            'description' => $request->description,
            'user_edit' => auth()->user()->id,
            'state' => $state
        ]);

        $categorizationUpdated = Categorization::find($id, ['id_categorization AS id','name', 'description','state']);

        return response()->json([
            'message' => 'Categorization Update',
            'data' => $categorizationUpdated
        ], Response::HTTP_OK);

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Categorization  $categorization
     * @return \Illuminate\Http\Response
     */
    public function destroy(Categorization $categorization)
    {
        $categorization->delete();

        return response()->json([
            'message' => 'Categorization Destroyed'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }

    /**
     * Logical delete register
     *
     */
    public function delete($id)
    {
        Categorization::findOrFail($id)->update([
            'state' => "E"
        ]);

        return response()->json([
            'message' => 'Categorization Deleted',
            'data' => 'true'
        ], Response::HTTP_ACCEPTED);
    }
}
