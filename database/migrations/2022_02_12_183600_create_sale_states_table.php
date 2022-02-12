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
        Schema::dropIfExists('sale_states');
    }
}
