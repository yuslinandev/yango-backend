<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProductPricesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('product_prices', function (Blueprint $table) {
            $table->integer('id_product_price', true);
            $table->integer('id_product');
            $table->smallInteger('id_local');
            $table->string('price_type', 5)->nullable();
            $table->string('currency', 5)->nullable();
            $table->string('price_condition', 10)->nullable();
            $table->decimal('price', 14, 4);
            $table->dateTime('validity_date_start', 6);
            $table->dateTime('validity_date_end', 6);
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
        Schema::dropIfExists('product_prices');
    }
}
