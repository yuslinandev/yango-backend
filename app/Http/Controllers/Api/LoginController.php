<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

use App\Models\User; // llamar al modelo usuario
use Illuminate\Support\Facades\Auth; // clase para inicio de sesion

class LoginController extends Controller
{
    public function login(Request $request)
    {
        // Primero validamos los campos
        $this->validateLogin($request);

        // login true
        /*
        Auth::attempt($credentials)
        */
        if( Auth::attempt( $request->only('email','password') ) ){
            return response()->json([
                /*
                    basado en el usuario, crea un token con el nombre de usuario
                    y se pasa a un texto plano
                    */
                'token' => $request->user()->createToken( $request->name )->plainTextToken,
                'message' => 'Success'
            ]);
        }

        // login false
        return response()->json([
            'message' => 'Unauthenticated.'
        ]);
    }

    public function validateLogin(Request $request)
    {
        return $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'name' => 'required',
        ]);
    }
}
