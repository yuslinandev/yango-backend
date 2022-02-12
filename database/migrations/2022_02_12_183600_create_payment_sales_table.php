<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePaymentSalesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('payment_sales', function (Blueprint $table) {
            $table->integer('id_payment_sale', true);
            $table->integer('id_payment')->nullable();
            $table->integer('id_sale')->nullable();
            $table->integer('id_sale_order')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('payment_sales');
    }
}
