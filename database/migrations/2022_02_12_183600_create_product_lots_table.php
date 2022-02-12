<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProductLotsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('product_lots', function (Blueprint $table) {
            $table->integer('id_product_lot', true);
            $table->integer('id_product');
            $table->string('lot_code', 30)->nullable()->index('idx_prod_lot_code');
            $table->smallInteger('id_unit_quantity');
            $table->decimal('quantity', 14, 4);
            $table->integer('id_unit_weight')->nullable();
            $table->decimal('weight', 10, 4)->nullable();
            $table->dateTime('production_date', 6)->nullable();
            $table->dateTime('buy_date', 6)->nullable();
            $table->dateTime('expiration_date', 6)->nullable();
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
        Schema::dropIfExists('product_lots');
    }
}
