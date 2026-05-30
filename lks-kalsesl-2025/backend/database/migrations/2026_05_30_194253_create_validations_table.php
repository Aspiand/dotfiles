<?php

use App\Models\JobCategory;
use App\Models\Society;
use App\Models\Validator;
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
        Schema::create('validations', function (Blueprint $table) {
            $table->id();
            $table->foreignIdFor(JobCategory::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(JobCategory::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(Society::class)->constrained()->cascadeOnDelete();
            $table->foreignIdFor(Validator::class)->constrained()->cascadeOnDelete();
            $table->enum('status', ['accepted', 'declined', 'pending']);
            $table->text('work_experience');
            $table->text('job_position');
            $table->text('reason_accepted');
            $table->text('validator_notes');
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('validations');
    }
};
