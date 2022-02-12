<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePurchaseDetailsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('purchase_details', function (Blueprint $table) {
            $table->integer('id_purchase_detail', true);
            $table->integer('id_purchase')->nullable();
            $table->integer('id_product')->nullable();
            $table->string('product_description', 400)->nullable();
            $table->smallInteger('id_unit')->nullable();
            $table->decimal('quantity', 14, 4)->nullable();
            $table->decimal('discount', 14, 4)->nullable();
            $table->string('application_discount', 2)->nullable()->comment('Aplica a: P=Precio sin igv, PV=Precio venta con igv, T=Total sin igv, TV=Total con igv
');
            $table->decimal('price', 14, 4)->nullable();
            $table->decimal('price_igv', 14, 4)->nullable();
            $table->decimal('price_purchase', 14, 4)->nullable();
            $table->string('state', 5)->nullable();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('purchase_details');
    }
}
