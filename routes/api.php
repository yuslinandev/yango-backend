<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::apiResource('v1/brand', App\Http\Controllers\Api\V1\BrandController::class)
    ->only(['index','show','destroy','store','update'])
    ->middleware('auth:sanctum');

//Login
Route::post('login', [
    App\Http\Controllers\Api\LoginController::class,
    'login'
]);