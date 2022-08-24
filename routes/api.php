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
    Route::get('/v1/brand_list', [App\Http\Controllers\Api\V1\BrandController::class, 'list']);
    Route::post('/v1/brand_store', [App\Http\Controllers\Api\V1\BrandController::class, 'store']);
    Route::patch('/v1/brand_update', [App\Http\Controllers\Api\V1\BrandController::class, 'update']);
    Route::delete('/v1/brand_delete/{id}', [App\Http\Controllers\Api\V1\BrandController::class, 'delete']);

    // Endpoints Units
    Route::get('/v1/unit_list', [App\Http\Controllers\Api\V1\UnitController::class, 'list']);
    Route::post('/v1/unit_store', [App\Http\Controllers\Api\V1\UnitController::class, 'store']);
    Route::patch('/v1/unit_update', [App\Http\Controllers\Api\V1\UnitController::class, 'update']);
    Route::delete('/v1/unit_delete/{id}', [App\Http\Controllers\Api\V1\UnitController::class, 'delete']);
    Route::apiResource('v1/unit', App\Http\Controllers\Api\V1\UnitController::class)
    ->only(['index','show','destroy','store','update']);

    // Endpoints Categorizations
    Route::get('/v1/categorization_list', [App\Http\Controllers\Api\V1\CategorizationController::class, 'list']);
    Route::post('/v1/categorization_store', [App\Http\Controllers\Api\V1\CategorizationController::class, 'store']);
    Route::patch('/v1/categorization_update', [App\Http\Controllers\Api\V1\CategorizationController::class, 'update']);
    Route::delete('/v1/categorization_delete/{id}', [App\Http\Controllers\Api\V1\CategorizationController::class, 'delete']);
    Route::apiResource('v1/categorization', App\Http\Controllers\Api\V1\CategorizationController::class)
    ->only(['index','show','destroy','store','update']);

    // Endpoints Classification
    Route::get('/v1/classification_list', [App\Http\Controllers\Api\V1\ClassificationController::class, 'list']);
    Route::post('/v1/classification_store', [App\Http\Controllers\Api\V1\ClassificationController::class, 'store']);
    Route::patch('/v1/classification_update', [App\Http\Controllers\Api\V1\ClassificationController::class, 'update']);
    Route::delete('/v1/classification_delete/{id}', [App\Http\Controllers\Api\V1\ClassificationController::class, 'delete']);
    Route::apiResource('v1/classification', App\Http\Controllers\Api\V1\ClassificationController::class)
    ->only(['index','show','destroy','store','update']);


    // Endpoints Employees
    Route::apiResource('v1/employee', App\Http\Controllers\Api\V1\EmployeeController::class)
    ->only(['index']);

    // Endpoints Movements
    Route::apiResource('v1/movement', App\Http\Controllers\Api\V1\MovementController::class)
    ->only(['store']);

});
