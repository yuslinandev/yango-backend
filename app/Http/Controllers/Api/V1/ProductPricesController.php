<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Product_prices;
use Illuminate\Http\Request;
use App\Http\Resources\V1\ProductPricesCollection; // llamar al recurso
use Symfony\Component\HttpFoundation\Response; // lista de codigos de estado

class ProductPricesController extends Controller
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
        $orderField = $request->input('orderField') ?? 'price_type';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'price_type';
        $search = $request->input('search') ?? '';

        if($search != ""){
            $productPrice = Product_prices::where( 'price_type', 'LIKE', '%' . $search . '%' )
                ->orwhere( 'currency', 'LIKE', '%' . $search . '%' )
                ->where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }else{
            $productPrice = Product_prices::where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }

        return response()->json(
            new ProductPricesCollection( $productPrice )
        , Response::HTTP_OK);

    }


public function listByLocalAndProduct(Request $request)
    {

        // Valores por defecto
        // page por default
        $size =  $request->input('size') ?? 10;
        $orderField = $request->input('orderField') ?? 'price_type';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'price_type';
        $search = $request->input('search') ?? '';
        $id_local = $request->input('id_local') ?? '';
        $id_product = $request->input('id_product') ?? '';


            $productPrice = Product_prices::where( 'id_local', '=', $id_local)
                ->where( 'id_product', '=', $id_product)
                ->where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);

        return response()->json(
            new ProductPricesCollection( $productPrice )
        , Response::HTTP_OK);

    }


        public function listAll()
            {
                    $productPrice = Product_prices::get();


                return response()->json(
                    $productPrice
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
        // ver archivo de ProductPricesResource
        return ProductPricesResource::collection(Product_prices::latest()->paginate());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $this->validateProductPrices($request);

        //dd($request->all());

        $date1= date('Y-m-d H:i:s', strtotime($request->validity_date_start));
        $date2= date('Y-m-d H:i:s', strtotime($request->validity_date_end));
        $productPrice = Product_prices::create([

        'id_product' => $request->id_product,
        'id_local' => $request->id_local,
        'price_type' => $request->price_type,
        'currency' => $request->currency,
        'price_condition' => $request->price_condition,
        'price' => $request->price,
        'validity_date_start' => $date1,
        'validity_date_end' =>  $date2,
        'state' => $request->state,
        'user_creation' => auth()->user()->id


        ]);

        $productPriceInserted = Product_prices::find($productPrice->id_product_price, ['id_product_price AS id','id_product',
                                                                                                               'id_local',
                                                                                                               'price_type',
                                                                                                               'currency',
                                                                                                               'price_condition',
                                                                                                               'price',
                                                                                                               'validity_date_start',
                                                                                                               'validity_date_end',
                                                                                                               'state',
                                                                                                               'user_creation',
                                                                                                               'created_at']);

        return response()->json([
            'message' => 'ProductPrices Add',
            'data' => $productPriceInserted
        ], Response::HTTP_OK);
    }

    public function validateProductPrices(Request $request)
    {
        return $request->validate([
            'id_product' => 'required',
            'id_local' => 'required'
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\ProductPrices  $productPrice
     * @return \Illuminate\Http\Response
     */
    public function show(ProductPrices $productPrice)
    {
        return new ProductPricesResource($productPrice);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\ProductPrices  $productPrice
     * @return \Illuminate\Http\Response
     */

      public function updateStatus(Request $request){
      $id = $request->id;
        $state = $request->state;

              if (strval($state) ==  "A" ) {
                    $state = "I" ;
              } else
              {
                   $state = "A" ;
              }

              $productPrice = Product_prices::findOrFail($id)->update([

                      'state' => $state,
                     'user_edit' => auth()->user()->id

              ]);

                      $productPriceUpdated = Product_prices::find($id, ['id_product_price AS id','id_product',
                      'id_local',
                      'price_type',
                      'currency',
                      'price_condition',
                      'price',
                      'validity_date_start',
                      'validity_date_end',
                      'state',
                      'user_creation',
                      'created_at']);

                      return response()->json([
                          'message' => 'ProductPrices Update',
                          'data' => $productPriceUpdated
                      ], Response::HTTP_OK);


      }

    public function update(Request $request)
    {
        $id = $request->id;

        $this->validateProductPrices($request);

        //dd($request->all());
        // $productPrice->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        // Aqui podemos personalizar los valore a guardar
        $state = $request->state;
        if (strval($state) ==  true ) {
              $state = "A" ;
        } else
        {
             $state = "E" ;
        }
        $productPrice = Product_prices::findOrFail($id)->update([

          'id_product' => $request->id_product,
                'id_local' => $request->id_local,
                'price_type' => $request->price_type,
                'currency' => $request->currency,
                'price_condition' => $request->price_condition,
                'price' => $request->price,
                'validity_date_start' => $request->validity_date_start,
                'validity_date_end' => $request->validity_date_end,
                'state' => $state,
                'created_at'  => $request->created_at,
                'user_edit' => auth()->user()->id

        ]);

        $productPriceUpdated = Product_prices::find($id, ['id_product_price AS id','id_product',
        'id_local',
        'price_type',
        'currency',
        'price_condition',
        'price',
        'validity_date_start',
        'validity_date_end',
        'state',
        'user_creation',
        'created_at']);

        return response()->json([
            'message' => 'ProductPrices Update',
            'data' => $productPriceUpdated
        ], Response::HTTP_OK);

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\ProductPrices  $productPrice
     * @return \Illuminate\Http\Response
     */
    public function destroy(ProductPrices $productPrice)
    {
        $productPrice->delete();

        return response()->json([
            'message' => 'ProductPrices Destroyed'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }

    /**
     * Logical delete register
     *
     */
    public function delete($id)
    {
        Product_prices::findOrFail($id)->update([
            'state' => "E"
        ]);

        return response()->json([
            'message' => 'ProductPrices Deleted',
            'data' => 'true'
        ], Response::HTTP_ACCEPTED);
    }
}
