<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePaymentFilesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('payment_files', function (Blueprint $table) {
            $table->integer('id_payment_file')->primary();
            $table->integer('id_payment')->nullable();
            $table->string('filename_user', 45)->nullable();
            $table->string('filename_system', 45)->nullable();
            $table->string('commentary', 45)->nullable();
            $table->string('state', 45)->nullable();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('payment_files');
    }
}
