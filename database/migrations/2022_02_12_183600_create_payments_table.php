<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePaymentsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('payments', function (Blueprint $table) {
            $table->integer('id_payment', true);
            $table->string('internal_code', 20);
            $table->integer('id_bank')->nullable();
            $table->dateTime('date', 6);
            $table->string('payment_method', 5);
            $table->decimal('value', 14, 4);
            $table->string('currency', 5);
            $table->decimal('exchange_rate', 10, 4)->nullable();
            $table->string('commentary', 200)->nullable();
            $table->string('voucher', 50)->nullable();
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
        Schema::dropIfExists('payments');
    }
}
