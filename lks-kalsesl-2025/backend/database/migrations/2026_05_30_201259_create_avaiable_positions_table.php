<?php

use App\Models\JobVacancie;
use App\Models\JobVacancy;
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('avaiable_positions', function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(JobVacancy::class)->constrained()->cascadeOnDelete();
            $table->string('position');
            $table->bigInteger('capacity');
            $table->bigInteger('apply_capacity');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('avaiable_positions');
    }
};
