<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateSaleStatesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('sale_states', function (Blueprint $table) {
            $table->integer('id_sale_state', true);
            $table->integer('id_sale');
            $table->string('state_sale', 5)->nullable();
            $table->char('current', 1)->nullable();
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
        Schema::dropIfExists('sale_states');
    }
}
