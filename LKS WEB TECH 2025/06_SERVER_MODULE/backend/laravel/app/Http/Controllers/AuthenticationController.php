<?php

namespace App\Http\Controllers;

use App\Models\Societies;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthenticationController extends Controller
{
    public function login(Request $request){

        $request->validate([
            'id_card_number' => 'required',
            'password' => 'required',
        ]);

        $societ = Societies::where('id_card_number', $request->id_card_number)->first();

        if($societ && $request->password && $societ->password){
            $token = $societ->createToken('auth_token')->plainTextToken;

            return response()->json([
                'name' => $societ->name,
                'born_date' => $societ->born_date,
                'gender' => $societ->gender,
                'address' => $societ->address,
                'token'=> $token,
                'regional' => [
                    'id' => $societ->regional->id,
                    'province' => $societ->regional->province,
                    'disctrict' => $societ->regional->disctrict
                ]
            ],200);
        }

        return response()->json( [
                'message' => 'ID Card Number or password incorrect'
        ],401);
    }

    public function logout(Request $request){

        if (empty($request->user())) {
            return response()->json([
                'message' => 'Invalid Token'
            ],401);
        }

        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'message' => 'Logout Success'
        ]);
    }
}
