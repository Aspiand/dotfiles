<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Validator extends Model
{
    protected $fillable = [
        'user_id',
        'role',
        'name'
    ];

    public function user(){
        return $this->hasMany(User::class);
    }
}
