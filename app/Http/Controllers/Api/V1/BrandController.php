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
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
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
