<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Classification;
use Illuminate\Http\Request;
use App\Http\Resources\V1\ClassificationCollection; // llamar al recurso
use Symfony\Component\HttpFoundation\Response; // lista de codigos de estado

class ClassificationController extends Controller
{
    /**
     * Display a listing custom of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function list(Request $request)
    {
        // Obtener data de la url, ej:
        http://127.0.0.1:8000/api/v1/classification_list?page=1&toShow=5&sortField=name&sort=DESC

        // Valores por defecto
        // page por default
        $size =  $request->input('size') ?? 10;
        $orderField = $request->input('orderField') ?? 'name';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'name';
        $search = $request->input('search') ?? '';

        if($search != ""){
            $classification = Classification::where( 'name', 'LIKE', '%' . $search . '%' )
                ->orwhere( 'description', 'LIKE', '%' . $search . '%' )
                ->where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }else{
            $classification = Classification::where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }

        return response()->json(
            new ClassificationCollection( $classification )
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
        // ver archivo de ClassificationResource
        return ClassificationResource::collection(Classification::latest()->paginate());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $this->validateClassification($request);

        //dd($request->all());

        $classification = Classification::create([
            'name' => $request->name,
            'description' => $request->description,
            'parent_id' => $request->parent_id,
            'user_creation' => auth()->user()->id
        ]);

        $classificationInserted = Classification::find($classification->id_classification, ['id_classification AS id','name', 'description','state']);

        return response()->json([
            'message' => 'Classification Add',
            'data' => $classificationInserted
        ], Response::HTTP_OK);
    }

    public function validateClassification(Request $request)
    {
        return $request->validate([
            'name' => 'required'
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Classification  $classification
     * @return \Illuminate\Http\Response
     */
    public function show(Classification $classification)
    {
        return new ClassificationResource($classification);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Classification  $classification
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $id = $request->id;

        $this->validateClassification($request);

        //dd($request->all());

        // $classification->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        $state = $request->state;
        if (strval($state) ==  true ) {
              $state = "A" ;
        } else
        {
             $state = "E" ;
        }
        // Aqui podemos personalizar los valore a guardar
        $classification = Classification::findOrFail($id)->update([
            'name' => $request->name,
            'description' => $request->description,
            'user_edit' => auth()->user()->id,
            'state' => $state
        ]);

        $classificationUpdated = Classification::find($id, ['id_classification AS id','name', 'description','state']);

        return response()->json([
            'message' => 'Classification Update',
            'data' => $classificationUpdated
        ], Response::HTTP_OK);

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Classification  $classification
     * @return \Illuminate\Http\Response
     */
    public function destroy(Classification $classification)
    {
        $classification->delete();

        return response()->json([
            'message' => 'Classification Destroyed'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }

    /**
     * Logical delete register
     *
     */
    public function delete($id)
    {
        Classification::findOrFail($id)->update([
            'state' => "E"
        ]);

        return response()->json([
            'message' => 'Classification Deleted',
            'data' => 'true'
        ], Response::HTTP_ACCEPTED);
    }
}
