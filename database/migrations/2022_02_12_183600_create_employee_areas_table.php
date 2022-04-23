<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateEmployeeAreasTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('employee_areas', function (Blueprint $table) {
            $table->integer('id_employee_area', true);
            $table->string('name', 20);
            $table->string('description', 100)->nullable();
            $table->string('state', 5)->default('A');
            $table->smallInteger('user_creation');
            $table->smallInteger('user_edit')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('employee_areas');
    }
}
