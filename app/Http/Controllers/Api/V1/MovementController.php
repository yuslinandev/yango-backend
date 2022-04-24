<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Movement;
use App\Models\MovementDetail;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response; // lista de codigos de estado
use Illuminate\Support\Facades\DB;

class MovementController extends Controller
{
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        try {
            DB::transaction(function() use ($request) {
                
            $movement = Movement::create([
                'document_number' => $request->document_number,
                'document_type' => $request->document_type,
                'commentary' => $request->commentary,
                'user_creation' => auth()->user()->id
            ]);
            $movement_id = $movement->id_movement;

            foreach($request->details as $detail){
                $movementDetail = MovementDetail::create([
                    'id_movement' => $movement_id,
                    'id_product' => $detail['id_product'],
                    'id_unit' => 0,
                    'quantity' => $detail['quantity'],
                    'value' => $detail['value'],
                    'user_creation' => auth()->user()->id
                ]);
            }
            });
        } catch (\Exception $e) {
            return response()->json([
                'message' => $e->getMessage()
            ],Response::HTTP_NOT_FOUND);
        }
        return response()->json(['message' => 'Success'],Response::HTTP_OK);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Movement  $movement
     * @return \Illuminate\Http\Response
     */
    public function show(Movement $movement)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Movement  $movement
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request, Movement $movement)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Movement  $movement
     * @return \Illuminate\Http\Response
     */
    public function destroy(Movement $movement)
    {
        //
    }
}
