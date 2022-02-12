<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateRoutesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('routes', function (Blueprint $table) {
            $table->integer('id_route', true);
            $table->string('name', 20);
            $table->string('description', 100)->nullable();
            $table->string('route_type', 5);
            $table->integer('id_vehicle')->nullable();
            $table->integer('id_employee_driver')->nullable();
            $table->dateTime('departure_date', 6)->nullable();
            $table->dateTime('arrival_date', 6)->nullable();
            $table->tinyInteger('number_passengers')->nullable();
            $table->char('allow_travel_expenses', 1)->nullable();
            $table->smallInteger('delivery_duration')->nullable();
            $table->char('weekday_scheduled', 1)->nullable();
            $table->string('time_scheduled', 10)->nullable();
            $table->integer('id_route_base')->nullable();
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
        Schema::dropIfExists('routes');
    }
}
