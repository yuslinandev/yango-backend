<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateVehiclesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('vehicles', function (Blueprint $table) {
            $table->integer('id_vehicle', true);
            $table->string('name', 20)->nullable();
            $table->string('license_plate', 10);
            $table->integer('id_employee_driver_assigned')->nullable();
            $table->string('internal_code', 20);
            $table->string('type_vehicle', 5);
            $table->tinyInteger('passenger_capacity')->nullable();
            $table->smallInteger('load_capacity_kg')->nullable();
            $table->string('state', 5);
            $table->smallInteger('user_creation');
            $table->dateTime('created_at', 6);
            $table->smallInteger('user_edit')->nullable();
            $table->dateTime('updated_at', 6)->nullable();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('vehicles');
    }
}
