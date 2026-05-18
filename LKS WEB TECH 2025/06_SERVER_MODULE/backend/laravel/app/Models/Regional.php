<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Regional extends Model
{
   protected $fillable = [
    "province",
    "district",
   ];

   public function societies()  {
        return $this->hasMany(Societies::class);
   }
}
