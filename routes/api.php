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
    Route::get('/v1/brand_list', [App\Http\Controllers\Api\V1\BrandController::class, 'list']);
    Route::post('/v1/brand_store', [App\Http\Controllers\Api\V1\BrandController::class, 'store']);
    Route::patch('/v1/brand_update', [App\Http\Controllers\Api\V1\BrandController::class, 'update']);
    Route::delete('/v1/brand_delete/{id}', [App\Http\Controllers\Api\V1\BrandController::class, 'delete']);
    Route::get('/v1/brand_listAll', [App\Http\Controllers\Api\V1\BrandController::class, 'listAll']);
    Route::apiResource('v1/brand', App\Http\Controllers\Api\V1\BrandController::class)
    ->only(['index','show','destroy','store','update']);

    // Endpoints Units
    Route::get('/v1/unit_list', [App\Http\Controllers\Api\V1\UnitController::class, 'list']);
    Route::post('/v1/unit_store', [App\Http\Controllers\Api\V1\UnitController::class, 'store']);
    Route::patch('/v1/unit_update', [App\Http\Controllers\Api\V1\UnitController::class, 'update']);
    Route::delete('/v1/unit_delete/{id}', [App\Http\Controllers\Api\V1\UnitController::class, 'delete']);
    Route::get('/v1/unit_listAll', [App\Http\Controllers\Api\V1\UnitController::class, 'listAll']);
    Route::apiResource('v1/unit', App\Http\Controllers\Api\V1\UnitController::class)
    ->only(['index','show','destroy','store','update']);



    // Endpoints Categorizations
    Route::get('/v1/categorization_list', [App\Http\Controllers\Api\V1\CategorizationController::class, 'list']);
    Route::post('/v1/categorization_store', [App\Http\Controllers\Api\V1\CategorizationController::class, 'store']);
    Route::patch('/v1/categorization_update', [App\Http\Controllers\Api\V1\CategorizationController::class, 'update']);
    Route::delete('/v1/categorization_delete/{id}', [App\Http\Controllers\Api\V1\CategorizationController::class, 'delete']);
    Route::get('/v1/categorization_listAll', [App\Http\Controllers\Api\V1\CategorizationController::class, 'listAll']);
    Route::apiResource('v1/categorization', App\Http\Controllers\Api\V1\CategorizationController::class)
    ->only(['index','show','destroy','store','update']);


    // Endpoints Classification
    Route::get('/v1/classification_list', [App\Http\Controllers\Api\V1\ClassificationController::class, 'list']);
    Route::post('/v1/classification_store', [App\Http\Controllers\Api\V1\ClassificationController::class, 'store']);
    Route::patch('/v1/classification_update', [App\Http\Controllers\Api\V1\ClassificationController::class, 'update']);
    Route::delete('/v1/classification_delete/{id}', [App\Http\Controllers\Api\V1\ClassificationController::class, 'delete']);
    Route::get('/v1/classification_listAll', [App\Http\Controllers\Api\V1\ClassificationController::class, 'listAll']);
    Route::apiResource('v1/classification', App\Http\Controllers\Api\V1\ClassificationController::class)
    ->only(['index','show','destroy','store','update']);



    // Endpoints Employees
    Route::get('/v1/employee_list', [App\Http\Controllers\Api\V1\EmployeeController::class, 'list']);
    Route::post('/v1/employee_store', [App\Http\Controllers\Api\V1\EmployeeController::class, 'store']);
    Route::patch('/v1/employee_update', [App\Http\Controllers\Api\V1\EmployeeController::class, 'update']);
    Route::delete('/v1/employee_delete/{id}', [App\Http\Controllers\Api\V1\EmployeeController::class, 'delete']);
    Route::apiResource('v1/employee', App\Http\Controllers\Api\V1\EmployeeController::class)
    ->only(['index','show','destroy','store','update']);


    // Endpoints Job
    Route::get('/v1/job_list', [App\Http\Controllers\Api\V1\JobController::class, 'list']);
    Route::post('/v1/job_store', [App\Http\Controllers\Api\V1\JobController::class, 'store']);
    Route::patch('/v1/job_update', [App\Http\Controllers\Api\V1\JobController::class, 'update']);
    Route::delete('/v1/job_delete/{id}', [App\Http\Controllers\Api\V1\JobController::class, 'delete']);
    Route::apiResource('v1/job', App\Http\Controllers\Api\V1\JobController::class)
    ->only(['index','show','destroy','store','update']);

    // Endpoints area
    Route::get('/v1/area_list', [App\Http\Controllers\Api\V1\AreaController::class, 'list']);
    Route::post('/v1/area_store', [App\Http\Controllers\Api\V1\AreaController::class, 'store']);
    Route::patch('/v1/area_update', [App\Http\Controllers\Api\V1\AreaController::class, 'update']);
    Route::delete('/v1/area_delete/{id}', [App\Http\Controllers\Api\V1\AreaController::class, 'delete']);
    Route::apiResource('v1/area', App\Http\Controllers\Api\V1\AreaController::class)
    ->only(['index','show','destroy','store','update']);

    // Endpoints local
    Route::get('/v1/local_list', [App\Http\Controllers\Api\V1\LocalController::class, 'list']);
    Route::post('/v1/local_store', [App\Http\Controllers\Api\V1\LocalController::class, 'store']);
    Route::patch('/v1/local_update', [App\Http\Controllers\Api\V1\LocalController::class, 'update']);
    Route::delete('/v1/local_delete/{id}', [App\Http\Controllers\Api\V1\LocalController::class, 'delete']);
    Route::get('/v1/local_listAll', [App\Http\Controllers\Api\V1\LocalController::class, 'listAll']);
    Route::apiResource('v1/local', App\Http\Controllers\Api\V1\LocalController::class)
    ->only(['index','show','destroy','store','update']);

    // Endpoints warehouse
    Route::get('/v1/warehouse_list', [App\Http\Controllers\Api\V1\WarehouseController::class, 'list']);
    Route::post('/v1/warehouse_store', [App\Http\Controllers\Api\V1\WarehouseController::class, 'store']);
    Route::patch('/v1/warehouse_update', [App\Http\Controllers\Api\V1\WarehouseController::class, 'update']);
    Route::delete('/v1/warehouse_delete/{id}', [App\Http\Controllers\Api\V1\WarehouseController::class, 'delete']);
    Route::apiResource('v1/warehouse', App\Http\Controllers\Api\V1\WarehouseController::class)
    ->only(['index','show','destroy','store','update']);

    // Endpoints products
    Route::get('/v1/product_list', [App\Http\Controllers\Api\V1\ProductController::class, 'list']);
    Route::post('/v1/product_store', [App\Http\Controllers\Api\V1\ProductController::class, 'store']);
    Route::patch('/v1/product_update', [App\Http\Controllers\Api\V1\ProductController::class, 'update']);
    Route::delete('/v1/product_delete/{id}', [App\Http\Controllers\Api\V1\ProductController::class, 'delete']);
    Route::apiResource('v1/product', App\Http\Controllers\Api\V1\ProductController::class)
    ->only(['index','show','destroy','store','update']);

    // Endpoints product_prices
    Route::get('/v1/product_prices_list', [App\Http\Controllers\Api\V1\ProductPricesController::class, 'list']);
    Route::post('/v1/product_prices_store', [App\Http\Controllers\Api\V1\ProductPricesController::class, 'store']);
    Route::patch('/v1/product_prices_update', [App\Http\Controllers\Api\V1\ProductPricesController::class, 'update']);
    Route::delete('/v1/product_prices_delete/{id}', [App\Http\Controllers\Api\V1\ProductPricesController::class, 'delete']);
    Route::get('/v1/product_prices_listAll', [App\Http\Controllers\Api\V1\ProductPricesController::class, 'listAll']);
    Route::get('/v1/product_prices_list_by_local_and_product', [App\Http\Controllers\Api\V1\ProductPricesController::class, 'listByLocalAndProduct']);
    Route::patch('/v1/product_prices_status_update', [App\Http\Controllers\Api\V1\ProductPricesController::class, 'updateStatus']);
    Route::apiResource('v1/product_prices', App\Http\Controllers\Api\V1\ProductPricesController::class)
    ->only(['index','show','destroy','store','update']);

    // Endpoints product_stocks
    Route::get('/v1/product_stocks_list', [App\Http\Controllers\Api\V1\ProductStocksController::class, 'list']);
    Route::post('/v1/product_stocks_store', [App\Http\Controllers\Api\V1\ProductStocksController::class, 'store']);
    Route::patch('/v1/product_stocks_update', [App\Http\Controllers\Api\V1\ProductStocksController::class, 'update']);
    Route::delete('/v1/product_stocks_delete/{id}', [App\Http\Controllers\Api\V1\ProductStocksController::class, 'delete']);
    Route::get('/v1/product_stocks_listAll', [App\Http\Controllers\Api\V1\ProductStocksController::class, 'listAll']);
    Route::apiResource('v1/product_stocks', App\Http\Controllers\Api\V1\ProductStocksController::class)
    ->only(['index','show','destroy','store','update']);

    // Endpoints configs
    Route::get('/v1/configs_list', [App\Http\Controllers\Api\V1\ConfigsController::class, 'list']);
    Route::post('/v1/configs_store', [App\Http\Controllers\Api\V1\ConfigsController::class, 'store']);
    Route::patch('/v1/configs_update', [App\Http\Controllers\Api\V1\ConfigsController::class, 'update']);
    Route::delete('/v1/configs_delete/{id}', [App\Http\Controllers\Api\V1\ConfigsController::class, 'delete']);
    Route::get('/v1/configs_listAll', [App\Http\Controllers\Api\V1\ConfigsController::class, 'listAll']);
    Route::get('/v1/configs_list_with_filters', [App\Http\Controllers\Api\V1\ConfigsController::class, 'listAllWithFilters']);
    Route::apiResource('v1/configs', App\Http\Controllers\Api\V1\ConfigsController::class)
    ->only(['index','show','destroy','store','update']);


    // Endpoints Employees
    Route::apiResource('v1/employee', App\Http\Controllers\Api\V1\EmployeeController::class)
    ->only(['index']);

    // Endpoints Movements
    Route::apiResource('v1/movement', App\Http\Controllers\Api\V1\MovementController::class)
    ->only(['store']);

});
