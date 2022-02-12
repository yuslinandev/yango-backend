<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateProductsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('products', function (Blueprint $table) {
            $table->integer('id_product', true);
            $table->string('internal_code', 20)->unique('idx_prod_internal_code');
            $table->string('short_name', 50);
            $table->string('long_name', 100);
            $table->string('description', 300)->nullable();
            $table->integer('id_brand')->nullable();
            $table->smallInteger('id_unit');
            $table->string('ids_classification', 20)->nullable();
            $table->integer('id_categorization');
            $table->string('product_type', 5)->nullable();
            $table->integer('id_image')->nullable();
            $table->smallInteger('life_time')->nullable();
            $table->smallInteger('id_unit_life_time')->nullable();
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
        Schema::dropIfExists('products');
    }
}
