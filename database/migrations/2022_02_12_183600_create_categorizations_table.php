<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateCategorizationsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('categorizations', function (Blueprint $table) {
            $table->integer('id_categorization', true);
            $table->string('name', 20);
            $table->string('description', 100)->nullable();
            $table->string('state', 5);
            $table->string('user_creation', 50);
            $table->dateTime('created_at', 6);
            $table->string('user_edit', 50)->nullable();
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
        Schema::dropIfExists('categorizations');
    }
}
