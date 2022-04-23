<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSaleDetailsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sale_details', function (Blueprint $table) {
            $table->integer('id_sale_detail', true);
            $table->integer('id_sale')->nullable();
            $table->integer('id_product')->nullable();
            $table->integer('id_product_ui')->nullable();
            $table->string('internal_code', 20)->nullable();
            $table->string('product_description', 400)->nullable();
            $table->smallInteger('id_unit')->nullable();
            $table->decimal('quantity', 14, 4)->nullable();
            $table->decimal('discount', 14, 4)->nullable();
            $table->string('application_discount', 2)->nullable()->comment('Aplica a: P=Precio sin igv, PV=Precio venta con igv, T=Total sin igv, TV=Total con igv
');
            $table->decimal('price', 14, 4)->nullable();
            $table->decimal('price_igv', 14, 4)->nullable();
            $table->decimal('price_sale', 14, 4)->nullable();
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
        Schema::dropIfExists('sale_details');
    }
}
