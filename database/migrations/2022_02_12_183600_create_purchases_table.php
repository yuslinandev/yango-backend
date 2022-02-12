<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePurchasesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('purchases', function (Blueprint $table) {
            $table->integer('id_purchase', true);
            $table->string('document_type', 5)->nullable();
            $table->string('serie', 5)->nullable();
            $table->string('number', 10)->nullable();
            $table->integer('id_supplier')->nullable();
            $table->string('ruc_supplier', 15)->nullable();
            $table->string('supplier_document_type', 5)->nullable();
            $table->string('supplier_document_number', 20)->nullable();
            $table->string('supplier_name', 200)->nullable();
            $table->date('date')->nullable();
            $table->decimal('percentage_igv', 6, 4)->nullable();
            $table->decimal('total_purchase', 14, 4)->nullable();
            $table->string('application_igv', 5)->nullable();
            $table->string('currency', 5)->nullable();
            $table->decimal('exchange_rate', 10, 4)->nullable();
            $table->integer('id_local_buy')->nullable();
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
        Schema::dropIfExists('purchases');
    }
}
