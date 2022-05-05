<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Brand;
use Illuminate\Http\Request;
use App\Http\Resources\V1\BrandResource; // llamar al recurso
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
        // Obtener data de la url, ej: http://127.0.0.1:8000/api/v1/brand_list?page=1&toShow=5&sort=ASC...
        // $page = $request->input('page');
        // $toShow = $request->input('toShow');
        // $field = $request->input('field');
        // $sort = $request->input('sort');
        // $textSearch = $request->input('textSearch');

        // dd es para que contiene variable, solo test
        //dd($toShow);

        // linea anterior
        //return BrandResource::collection(Brand::latest()->paginate($toShow));

        // Valores por defecto
        $toShow = 5;
        $field = 'name';
        $textSearch = 'maxime';
        if($textSearch != ""){
            $brand = Brand::where( $field, 'LIKE', '%' . $textSearch . '%' )->paginate ($toShow);
            $pagination = $brand->appends ( array (
                $field => $textSearch
             ) );
            // if (count ( $brand ) > 0)
            //  return $brand->withQuery ( $textSearch );
        }
        return response()->json([
            'data' => $brand,
            'pagination' => $pagination,
        ],  Response::HTTP_OK);
        
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
            'user_creation' => auth()->user()->id
        ]);

        /*$brand = new Brand;
        $brand->name = $request->name;
        $brand->description = $request->description;
        $brand->user_creation = auth()->user()->id;
        $brand->save();*/

        return response()->json([
            'message' => 'Brand Add'
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
    public function update(Request $request, Brand $brand)
    {
        $this->validateBrand($request);

        //dd($request->all());

        // $brand->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        // Aqui podemos personalizar los valore a guardar
        $brand = Brand::findOrFail($brand->id)->update([
            'name' => $request->name,
            'description' => $request->description,
            'user_edit' => auth()->user()->id,
            'state' => $request->state ? $request->state : "A"
        ]);

        return response()->json([
            'message' => 'Brand Update'
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
            'message' => 'Brand Deleted'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }
}
