<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSaleMovementDetailsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sale_movement_details', function (Blueprint $table) {
            $table->integer('id_sale_movement_detail', true);
            $table->integer('id_sale_detail')->nullable();
            $table->integer('id_movement_detail')->nullable();
            $table->integer('id_sale_order_detail')->nullable();
            $table->integer('id_sale_detail_base')->nullable();
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
        Schema::dropIfExists('sale_movement_details');
    }
}
