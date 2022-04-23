<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSaleOrdersTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sale_orders', function (Blueprint $table) {
            $table->integer('id_sale_order', true);
            $table->string('internal_code', 20)->nullable();
            $table->integer('id_customer');
            $table->date('date')->nullable();
            $table->integer('id_local')->nullable();
            $table->string('payment_method', 5)->comment('Tabla config = METODO_PAGO');
            $table->string('payment_terms', 5)->comment('Tabla config = CONDICION_PAGO');
            $table->decimal('percentage_igv', 6, 4);
            $table->decimal('total_sale', 14, 4);
            $table->string('application_igv', 5);
            $table->char('indicator_applied_igv', 1)->nullable()->comment('S=Grabada, N=No gravada o exonerada');
            $table->string('currency', 5)->comment('TIPO_MONEDA');
            $table->decimal('exchange_rate', 10, 4)->nullable();
            $table->string('commentary', 500)->nullable();
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
        Schema::dropIfExists('sale_orders');
    }
}
