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

    // Endpoints Brands
    Route::apiResource('v1/brand', App\Http\Controllers\Api\V1\BrandController::class)
    ->only(['index','show','destroy','store','update']);

    // Endpoints Brands
    Route::get('/v1/brand_list', [App\Http\Controllers\Api\V1\BrandController::class, 'list']);


    // Endpoints Employees
    Route::apiResource('v1/employee', App\Http\Controllers\Api\V1\EmployeeController::class)
    ->only(['index']);

    // Endpoints Movements
    Route::apiResource('v1/movement', App\Http\Controllers\Api\V1\MovementController::class)
    ->only(['store']);

});