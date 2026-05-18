<?php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class UserSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
         DB::table('users')->insert([
            'id_card_number' => "20210001",
            'password' => '1212112',
            'name' => 'Omar Gunawan',
            'born_date' => '1990-04-18',
            'gender' => 'male',
            'address' => 'Jln. Baranang Siang No. 479, DKI Jakarta',
        ]);
    }
}
