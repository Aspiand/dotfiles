<?php

use App\Models\JobVacancy;
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
        Schema::create('job_apply_societies', function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(Society::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(JobVacancy::class)->constrained()->cascadeOnDelete();
            $table->text('notes');
            $table->date('date');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('job_apply_societies');
    }
};
