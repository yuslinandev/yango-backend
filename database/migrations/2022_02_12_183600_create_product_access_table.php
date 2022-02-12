<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProductAccessTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('product_access', function (Blueprint $table) {
            $table->integer('id_product');
            $table->integer('id_local');
            $table->char('allow_view', 1)->nullable();
            $table->char('allow_edit', 1)->nullable();
            $table->char('allow_delete', 1)->nullable();
            $table->char('allow_view_stock', 1)->nullable();
            $table->char('allow_view_price', 1)->nullable();
            $table->char('allow_buy', 1)->nullable();
            $table->char('allow_sell', 1)->nullable();
            $table->smallInteger('user_edit')->nullable();
            $table->dateTime('updated_at', 6)->nullable();

            $table->primary(['id_product', 'id_local']);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('product_access');
    }
}
