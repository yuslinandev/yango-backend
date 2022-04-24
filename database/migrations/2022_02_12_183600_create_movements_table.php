<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateMovementsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('movements', function (Blueprint $table) {
            $table->integer('id_movement', true);
            $table->dateTime('date', 6)->nullable();
            $table->string('document_number', 20)->nullable();
            $table->string('document_type', 5)->nullable();
            $table->string('voucher_number', 20)->nullable();
            $table->string('voucher_type', 5)->nullable();
            $table->boolean('id_movement_type')->nullable();
            $table->smallInteger('id_local_origin')->nullable();
            $table->smallInteger('id_warehouse_origin')->nullable();
            $table->smallInteger('id_local_arrival')->nullable();
            $table->smallInteger('id_warehouse_arrival')->nullable();
            $table->integer('id_responsible_employee')->nullable();
            $table->integer('id_movement_transfer')->nullable();
            $table->string('commentary', 200)->nullable();
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
        Schema::dropIfExists('movements');
    }
}
