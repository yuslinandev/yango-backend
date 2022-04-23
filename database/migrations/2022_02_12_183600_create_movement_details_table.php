<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateMovementDetailsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('movement_details', function (Blueprint $table) {
            $table->integer('id_movement_detail', true);
            $table->integer('id_movement');
            $table->integer('id_product');
            $table->integer('id_product_lot')->nullable();
            $table->integer('id_product_ui')->nullable();
            $table->integer('id_product_formula')->nullable();
            $table->smallInteger('id_unit');
            $table->decimal('quantity', 14, 4);
            $table->decimal('quantity_formula', 14, 4)->nullable();
            $table->decimal('value', 14, 4)->nullable();
            $table->string('commentary', 100)->nullable();
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
        Schema::dropIfExists('movement_details');
    }
}
