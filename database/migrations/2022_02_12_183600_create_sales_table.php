<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSalesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sales', function (Blueprint $table) {
            $table->integer('id_sale', true);
            $table->string('document_type', 5);
            $table->string('serie', 5)->nullable();
            $table->string('number', 10);
            $table->integer('id_customer')->nullable();
            $table->string('ruc_customer', 15)->nullable();
            $table->string('customer_document_type', 5)->nullable();
            $table->string('customer_document_number', 20)->nullable();
            $table->string('customer_name', 200)->nullable();
            $table->date('date')->nullable();
            $table->decimal('percentage_igv', 6, 4)->nullable();
            $table->decimal('total_sale', 14, 4)->nullable();
            $table->string('application_igv', 5)->nullable();
            $table->string('currency', 5)->nullable();
            $table->decimal('exchange_rate', 10, 4)->nullable();
            $table->integer('id_local_sell')->nullable();
            $table->integer('id_warehouse_sell')->nullable();
            $table->char('reserve', 1)->nullable();
            $table->string('state', 5)->nullable();
            $table->smallInteger('user_creation')->nullable();
            $table->dateTime('created_at', 6)->nullable();
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
        Schema::dropIfExists('sales');
    }
}
