<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSaleSchedulesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sale_schedules', function (Blueprint $table) {
            $table->integer('id_sale_schedule', true);
            $table->integer('id_sale');
            $table->tinyInteger('fee_number');
            $table->decimal('value', 14, 4);
            $table->dateTime('date_scheduled', 6);
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
        Schema::dropIfExists('sale_schedules');
    }
}
