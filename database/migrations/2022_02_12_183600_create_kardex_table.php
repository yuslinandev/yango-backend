<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateKardexTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('kardex', function (Blueprint $table) {
            $table->integer('id_kardex', true);
            $table->integer('id_product');
            $table->dateTime('date', 6);
            $table->char('movement_type', 1);
            $table->integer('id_movement_detail');
            $table->decimal('quantity', 14, 4);
            $table->decimal('quantity_value', 14, 4);
            $table->decimal('balance', 14, 4);
            $table->decimal('balance_value', 14, 4);
            $table->string('commentary', 100)->nullable();
            $table->integer('id_local');
            $table->integer('id_warehouse');
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
        Schema::dropIfExists('kardex');
    }
}
