<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Product;
use Illuminate\Http\Request;
use App\Http\Resources\V1\ProductCollection;
use App\Http\Resources\V1\ProductResource;
use Symfony\Component\HttpFoundation\Response;
use Illuminate\Support\Facades\DB;

class ProductController extends Controller
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
        $orderField = $request->input('orderField') ?? 'short_name';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'short_name';
        $search = $request->input('search') ?? '';

        if($search != ""){
/*             $product = Product::where( 'short_name', 'LIKE', '%' . $search . '%' )
                ->orwhere( 'description', 'LIKE', '%' . $search . '%' )
                ->where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size); */

                $product = Product::select('products.*')
                ->leftJoin('brands as brands', 'products.id_brand', '=', 'brands.id_brand')
                ->leftJoin('units as units', 'products.id_unit', '=', 'units.id_unit')
                ->leftJoin('classifications as classifications', 'products.ids_classification', '=', 'classifications.id_classification')
                ->leftJoin('categorizations as categorizations', 'products.id_categorization', '=', 'categorizations.id_categorization')
                ->leftJoin('product_prices as product_prices', 'products.id_product', '=', 'product_prices.id_product')
                ->where( 'products.short_name', 'LIKE', '%' . $search . '%' )
                    ->orwhere( 'products.description', 'LIKE', '%' . $search . '%' )
                    ->where('products.state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);

        }else{
            //$product = Product::where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
             $product = Product::select('products.*')
            ->leftJoin('brands as brands', 'products.id_brand', '=', 'brands.id_brand')
            ->leftJoin('units as units', 'products.id_unit', '=', 'units.id_unit')
            ->leftJoin('classifications as classifications', 'products.ids_classification', '=', 'classifications.id_classification')
            ->leftJoin('categorizations as categorizations', 'products.id_categorization', '=', 'categorizations.id_categorization')
            ->leftJoin('product_prices as product_prices', 'products.id_product', '=', 'product_prices.id_product')
             ->where('products.state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }

        return response()->json(
            new ProductCollection( $product )
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
        // ver archivo de ProductResource
        return ProductResource::collection(Product::latest()->paginate());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $this->validateProduct($request);

        //dd($request->all());

        $product = Product::create([

                    'internal_code' => $request->internal_code,
                    'short_name' => $request->short_name,
                    'long_name' => $request->long_name,
                    'description' => $request->description,
                    'id_brand' => $request->id_brand,
                    'id_unit' => $request->id_unit,
                    'ids_classification' => $request->ids_classification,
                    'id_categorization' => $request->id_categorization,
                    'product_type' => $request->product_type,
                    'id_image' => $request->id_image,
                    'life_time' => $request->life_time,
                    'id_unit_life_time' => $request->id_unit_life_time,
                    'state' => $request->state,
                    'user_creation'  => auth()->user()->id
        ]);

        //$productInserted = Product::find($product->id_product, ['id_product','short_name','long_name',  'description','state', 'id_brand']);

$productInserted = Product::select('products.*')
            ->leftJoin('brands as brands', 'products.id_brand', '=', 'brands.id_brand')
            ->where('products.id_product', '=', $id)->first();

        return response()->json([
            'message' => 'Product Add',
            'data' => new ProductResource($productInserted)
        ], Response::HTTP_OK);
    }

    public function validateProduct(Request $request)
    {
        return $request->validate([
            'short_name' => 'required'
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Product  $product
     * @return \Illuminate\Http\Response
     */
    public function show(Product $product)
    {
        return new ProductResource($product);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Product  $product
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $id = $request->id_product;

        $this->validateProduct($request);

        //dd($request->all());

        // $product->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        // Aqui podemos personalizar los valore a guardar
         $state = $request->state;
                if (strval($state) ==  true ) {
                      $state = "A" ;
                } else
                {
                     $state = "I" ;
                }

        $product = Product::findOrFail($id)->update([
                    'internal_code' => $request->internal_code,
                    'short_name' => $request->short_name,
                    'long_name' => $request->long_name,
                    'description' => $request->description,
                    'id_brand' => $request->id_brand,
                    'id_unit' => $request->id_unit,
                    'ids_classification' => $request->ids_classification,
                    'id_categorization' => $request->id_categorization,
                    'product_type' => $request->product_type,
                    'id_image' => $request->id_image,
                    'life_time' => $request->life_time,
                    'id_unit_life_time' => $request->id_unit_life_time,
                    'state' => $state,
                    'user_creation'  => auth()->user()->id
        ]);

$productUpdated = Product::select('products.*')
            ->leftJoin('brands as brands', 'products.id_brand', '=', 'brands.id_brand')
            ->where('products.id_product', '=', $id)->first();
            //->first();

        //$productUpdated = Product::find($id, ['id_product','short_name','long_name',  'description','state', 'id_brand']);


        return response()->json([
            'message' => 'Product Update',
            'data' => new ProductResource($productUpdated)
            //'data' => $productUpdated
        ], Response::HTTP_OK);

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Product  $product
     * @return \Illuminate\Http\Response
     */
    public function destroy(Product $product)
    {
        $product->delete();

        return response()->json([
            'message' => 'Product Destroyed'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }

    /**
     * Logical delete register
     *
     */
    public function delete($id)
    {
        Product::findOrFail($id)->update([
            'state' => "E"
        ]);

        return response()->json([
            'message' => 'Product Deleted',
            'data' => 'true'
        ], Response::HTTP_ACCEPTED);
    }
}
