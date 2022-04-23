<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePersonPhonesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('person_phones', function (Blueprint $table) {
            $table->integer('id_person_phone', true);
            $table->string('description', 100)->nullable();
            $table->string('number_type', 5);
            $table->string('number', 20);
            $table->string('country_code', 5)->nullable();
            $table->string('city_code', 5)->nullable();
            $table->integer('id_person')->nullable();
            $table->integer('id_person_employee')->nullable();
            $table->integer('id_person_local')->nullable();
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
        Schema::dropIfExists('person_phones');
    }
}
