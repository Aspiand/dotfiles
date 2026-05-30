<?php

use App\Models\JobApplySociety;
use App\Models\JobVacancy;
use App\Models\Position;
use App\Models\Society;
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
        Schema::create('job_apply_positions', function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(Society::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(JobVacancy::class)->constrained()->cascadeOnDelete();
            // $table->foreignIdFor(Position::class)->constrained()->cascadeOnDelete();
            $table->foreignId('position_id')->references('id')->on('avaiable_positions')->cascadeOnDelete();
            $table->foreignIdFor(JobApplySociety::class)->constrained()->cascadeOnDelete();
            $table->date('date');
            $table->enum('status', ['pending', 'accepted', 'rejected']);
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('job_apply_positions');
    }
};
