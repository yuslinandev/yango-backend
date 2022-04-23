<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateLocalsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('locals', function (Blueprint $table) {
            $table->smallInteger('id_local', true);
            $table->string('internal_code', 5)->nullable();
            $table->string('short_name', 20);
            $table->string('long_name', 50);
            $table->string('description', 100)->nullable();
            $table->string('address', 100)->nullable();
            $table->integer('id_ubigeo')->nullable();
            $table->string('type', 5);
            $table->integer('id_responsible_employee')->nullable();
            $table->char('manage_warehouse', 1)->nullable();
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
        Schema::dropIfExists('locals');
    }
}
