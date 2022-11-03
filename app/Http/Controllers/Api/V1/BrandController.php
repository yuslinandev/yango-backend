<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Brand;
use Illuminate\Http\Request;
use App\Http\Resources\V1\BrandCollection; // llamar al recurso
use App\Http\Resources\V1\BrandResource;
use Symfony\Component\HttpFoundation\Response; // lista de codigos de estado

class BrandController extends Controller
{
    /**
     * Display a listing custom of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function list(Request $request)
    {
        // Obtener data de la url, ej:
        http://127.0.0.1:8000/api/v1/brand_list?page=1&toShow=5&sortField=name&sort=DESC

        // Valores por defecto
        // page por default
        $size =  $request->input('size') ?? 10;
        $orderField = $request->input('orderField') ?? 'name';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'name';
        $search = $request->input('search') ?? '';

        if($search != ""){
            $brand = Brand::where( 'name', 'LIKE', '%' . $search . '%' )
                ->orwhere( 'description', 'LIKE', '%' . $search . '%' )
                ->where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }else{
            $brand = Brand::where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);

        }

        return response()->json(
            new BrandCollection( $brand )
        , Response::HTTP_OK);

    }

    public function listAll()
        {
                $brand = Brand::where('state', '<>', 'E')->get();


            return response()->json(
                $brand
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
        // ver archivo de BrandResource
        return BrandResource::collection(Brand::latest()->paginate());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $this->validateBrand($request);

        //dd($request->all());

        $brand = Brand::create([
            'name' => $request->name,
            'description' => $request->description,
            'state' => $request->state,
            'user_creation' => auth()->user()->id
        ]);

        $brandInserted = Brand::find($brand->id_brand, ['id_brand AS id','name', 'description','state']);

        return response()->json([
            'message' => 'Brand Add',
            'data' => $brandInserted
        ], Response::HTTP_OK);
    }

    public function validateBrand(Request $request)
    {
        return $request->validate([
            'name' => 'required'
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Brand  $brand
     * @return \Illuminate\Http\Response
     */
    public function show(Brand $brand)
    {
        return new BrandResource($brand);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Brand  $brand
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $id = $request->id;

        $this->validateBrand($request);

        //dd($request->all());
        // $brand->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        // Aqui podemos personalizar los valore a guardar
        $state = $request->state;
        if (strval($state) ==  true ) {
              $state = "A" ;
        } else
        {
             $state = "I" ;
        }
        $brand = Brand::findOrFail($id)->update([
            'name' => $request->name,
            'description' => $request->description,
            'user_edit' => auth()->user()->id,
            'state' => $state
        ]);

        $brandUpdated = Brand::find($id, ['id_brand AS id','name', 'description','state']);

        return response()->json([
            'message' => 'Brand Update',
            'data' => $brandUpdated
        ], Response::HTTP_OK);

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Brand  $brand
     * @return \Illuminate\Http\Response
     */
    public function destroy(Brand $brand)
    {
        $brand->delete();

        return response()->json([
            'message' => 'Brand Destroyed'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }

    /**
     * Logical delete register
     *
     */
    public function delete($id)
    {
        Brand::findOrFail($id)->update([
            'state' => "E"
        ]);

        return response()->json([
            'message' => 'Brand Deleted',
            'data' => 'true'
        ], Response::HTTP_ACCEPTED);
    }
}
