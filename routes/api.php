<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

//Login
Route::post('login', [
    App\Http\Controllers\Api\LoginController::class,
    'login'
]);

Route::post('register', 'App\Http\Controllers\UserController@register');
Route::post('login', 'App\Http\Controllers\UserController@authenticate');

// Endpoints con jwt
Route::group(['middleware' => ['jwt.verify']], function() {

    Route::post('user','App\Http\Controllers\UserController@getAuthenticatedUser');
    Route::apiResource('v1/brand', App\Http\Controllers\Api\V1\BrandController::class)
    ->only(['index','show','destroy','store','update']);

});