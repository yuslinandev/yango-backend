<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateDeliveryPointsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('delivery_points', function (Blueprint $table) {
            $table->integer('id_delivery_point', true);
            $table->string('name', 20);
            $table->string('description', 100)->nullable();
            $table->string('delivery_point_type', 5);
            $table->string('address', 200)->nullable();
            $table->char('multiple_customers', 1);
            $table->integer('id_customer')->nullable();
            $table->integer('id_customer_local')->nullable();
            $table->integer('id_ubigeo')->nullable();
            $table->string('state', 5);
            $table->smallInteger('user_creation');
            $table->smallInteger('user_edit')->nullable();
            //$table->dateTime('updated_at', 6)->nullable();
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
        Schema::dropIfExists('delivery_points');
    }
}
