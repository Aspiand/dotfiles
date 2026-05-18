<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class Societies extends Authenticatable
{
    use HasFactory, Notifiable,HasApiTokens;

    protected $fillable = [
        "id_card_number","password","name","born_date","gender","address","login_tokens",
    ];

    public function regional()  {
        return $this->belongsTo(Regional::class);
    }
}
