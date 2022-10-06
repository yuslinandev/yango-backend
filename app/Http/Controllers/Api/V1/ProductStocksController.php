<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Product_stocks;
use Illuminate\Http\Request;
use App\Http\Resources\V1\ProductStocksCollection; // llamar al recurso
use Symfony\Component\HttpFoundation\Response; // lista de codigos de estado

class ProductStocksController extends Controller
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
        $orderField = $request->input('orderField') ?? 'id_product';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'id_product';
        $id_product = $request->input('id_product') ?? '';
        $id_local = $request->input('id_local') ?? '';
        $id_warehouse = $request->input('id_warehouse') ?? '';

        if($id_product != ""){
            $productStock = Product_stocks::where( 'id_product', '=', $id_product  )
                ->where( 'id_local', '=', $id_local  )
                ->where( 'id_warehouse', '=', $id_warehouse  )->orderBy($orderField, $order)->paginate ($size);
        }else{
            $productStock = Product_stocks::where('stock', '>=', '0')->orderBy($orderField, $order)->paginate ($size);
        }

        return response()->json(
            new ProductStocksCollection( $productStock )
        , Response::HTTP_OK);

    }

            public function listAll()
                {
                        $productStock = Product_stocks::get();


                    return response()->json(
                        $productStock
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
        // ver archivo de ProductStocksCollection
        return ProductStocksCollection::collection(Product_stocks::latest()->paginate());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $this->validateProductStock($request);

        //dd($request->all());

        $productStock = Product_stocks::create([
        'id_product' => $request->id_product,
         'id_local' => $request->id_local,
          'id_warehouse' => $request->id_warehouse,
          'date' => $request->date,
          'stock' => $request->stock,


        ]);

        $productStockInserted = Product_stocks::where( 'id_product', '=', $id_product  )
                                                              ->where( 'id_local', '=', $id_local  )
                                                              ->where( 'id_warehouse', '=', $id_warehouse  );

        return response()->json([
            'message' => 'ProductStock Add',
            'data' => $productStockInserted
        ], Response::HTTP_OK);
    }

    public function validateProductStock(Request $request)
    {
        return $request->validate([
            'id_product' => 'required',
            'id_warehouse' => 'required',
            'id_local' => 'required'
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\ProductStock  $productStock
     * @return \Illuminate\Http\Response
     */
    public function show(ProductStock $productStock)
    {
        return new ProductStocksCollection($productStock);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\ProductStock  $productStock
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $id = $request->id;

        $this->validateProductStock($request);

        //dd($request->all());
        // $productStock->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        // Aqui podemos personalizar los valore a guardar

        $productStock = Product_stocks::findOrFail($id)->update([

        'id_product' => $request->id_product,
         'id_local' => $request->id_local,
          'id_warehouse' => $request->id_warehouse,
          'date' => $request->date,
          'stock' => $request->stock,
        ]);

        $productStockUpdated = Product_stocks::where( 'id_product', '=', $id_product  )
                                                             ->where( 'id_local', '=', $id_local  )
                                                             ->where( 'id_warehouse', '=', $id_warehouse  );

        return response()->json([
            'message' => 'ProductStock Update',
            'data' => $productStockUpdated
        ], Response::HTTP_OK);

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\ProductStock  $productStock
     * @return \Illuminate\Http\Response
     */
    public function destroy(ProductStock $productStock)
    {
        $productStock->delete();

        return response()->json([
            'message' => 'ProductStock Destroyed'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }

    /**
     * Logical delete register
     *
     */
    public function delete(ProductStock $productStock)
    {
        $productStock->delete();

        return response()->json([
            'message' => 'ProductStock Deleted',
            'data' => 'true'
        ], Response::HTTP_ACCEPTED);
    }
}
