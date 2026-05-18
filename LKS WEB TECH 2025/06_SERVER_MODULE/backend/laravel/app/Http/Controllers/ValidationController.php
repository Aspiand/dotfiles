<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ValidationController extends Controller
{
    public function postValidation(Request $request)  {
        $request->validate([
            'job' => 'required',
            'job_description' => 'required',
            'income' => 'required',
            'reason_accepted' => 'required',
        ]);

        

    }
}
