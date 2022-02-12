<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProductStocksTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('product_stocks', function (Blueprint $table) {
            $table->integer('id_product');
            $table->smallInteger('id_local');
            $table->smallInteger('id_warehouse');
            $table->dateTime('date', 6);
            $table->decimal('stock', 14, 4);

            $table->primary(['id_product', 'id_local', 'id_warehouse']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('product_stocks');
    }
}
