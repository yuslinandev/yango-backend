<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSaleOrderDetailsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sale_order_details', function (Blueprint $table) {
            $table->integer('id_sale_order_detail', true);
            $table->integer('id_sale_order');
            $table->integer('id_product');
            $table->smallInteger('id_unit');
            $table->decimal('quantity_requested', 14, 4)->comment('SOLICITADA');
            $table->decimal('quantity_delivered', 14, 4)->comment('ENTREGADA');
            $table->decimal('price_sale', 14, 4);
            $table->decimal('price_igv', 14, 4)->nullable();
            $table->decimal('price_discount', 14, 4)->nullable();
            $table->decimal('total_sale', 14, 4);
            $table->string('commentary', 100)->nullable();
            $table->integer('id_warehouse_reserve')->nullable();
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
        Schema::dropIfExists('sale_order_details');
    }
}
