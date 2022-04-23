<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProductUisTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('product_uis', function (Blueprint $table) {
            $table->integer('id_product_ui', true);
            $table->integer('id_product');
            $table->integer('id_product_lot');
            $table->string('unique_identifier_code', 50)->nullable();
            $table->string('serie_number', 50)->nullable();
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
        Schema::dropIfExists('product_uis');
    }
}
