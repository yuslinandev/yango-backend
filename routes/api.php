<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

//Login
// Route::post('login', [
//     App\Http\Controllers\Api\LoginController::class,
//     'login'
// ]);

Route::post('register', 'App\Http\Controllers\UserController@register');
Route::post('login', 'App\Http\Controllers\UserController@authenticate');

// Endpoints con jwt
Route::group(['middleware' => ['jwt.verify']], function() {

    Route::get('user','App\Http\Controllers\UserController@getAuthenticatedUser');
    Route::get('validate','App\Http\Controllers\UserController@validateUserToken');

    // Endpoints Brands
    Route::apiResource('v1/brand', App\Http\Controllers\Api\V1\BrandController::class)
    ->only(['index','show','destroy','store','update']);

    // Endpoints Brands
    Route::get('/v1/brand_list', [App\Http\Controllers\Api\V1\BrandController::class, 'list']);
    Route::post('/v1/brand_store', [App\Http\Controllers\Api\V1\BrandController::class, 'store']);
    Route::patch('/v1/brand_update', [App\Http\Controllers\Api\V1\BrandController::class, 'update']);
    Route::delete('/v1/brand_delete/{id}', [App\Http\Controllers\Api\V1\BrandController::class, 'delete']);


    // Endpoints Employees
    Route::apiResource('v1/employee', App\Http\Controllers\Api\V1\EmployeeController::class)
    ->only(['index']);

    // Endpoints Movements
    Route::apiResource('v1/movement', App\Http\Controllers\Api\V1\MovementController::class)
    ->only(['store']);

});