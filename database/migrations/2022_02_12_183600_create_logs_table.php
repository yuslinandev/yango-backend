<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateLogsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('logs', function (Blueprint $table) {
            $table->integer('id_log', true);
            $table->string('table', 50);
            $table->string('field', 50);
            $table->string('action', 5);
            $table->string('previous_value', 50);
            $table->string('new_value', 50);
            $table->smallInteger('user_edit');
            $table->dateTime('updated_at', 6);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('logs');
    }
}
