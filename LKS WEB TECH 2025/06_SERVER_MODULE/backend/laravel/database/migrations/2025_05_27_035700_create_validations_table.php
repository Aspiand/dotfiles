<?php

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
            $table->foreignId('job_category_id')->constrained('job_categories')->cascade();
            $table->foreignId('society_id')->constrained('societies')->cascade();
            $table->foreignId('validator_id')->constrained('validators')->cascade()->nullable();
            $table->enum('status',['accepted','declined','pending']);
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
