<?php

use App\Http\Controllers\AuthenticationController;
use App\Http\Controllers\ValidationController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

// Route::get('/user', function (Request $request) {
//     return $request->user();
// })->middleware('auth:sanctum');


Route::post('v1/auth/login',[AuthenticationController::class,'login']);
Route::post( 'v1/auth/logout',[AuthenticationController::class,'logout'])->middleware('auth:sanctum');

Route::post('/v1/validation',[ValidationController::class,'postValidation'])->middleware('auth:sanctum');
