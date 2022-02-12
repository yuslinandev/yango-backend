<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateMovementTypesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('movement_types', function (Blueprint $table) {
            $table->boolean('id_movement_type')->primary();
            $table->string('short_name', 20);
            $table->string('long_name', 50);
            $table->string('description', 200);
            $table->string('prefix', 5);
            $table->char('type', 1);
            $table->string('state', 5);
            $table->boolean('visible');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('movement_types');
    }
}
