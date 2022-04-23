<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateClassificationsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('classifications', function (Blueprint $table) {
            $table->integer('id_classification', true);
            $table->string('name', 50);
            $table->string('description', 100)->nullable();
            $table->string('state', 5)->default('A');
            $table->smallInteger('user_creation');
            $table->smallInteger('user_edit')->nullable();
            //$table->dateTime('updated_at', 6)->nullable();
            $table->smallInteger('parent_id');
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
        Schema::dropIfExists('classifications');
    }
}
