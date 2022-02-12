<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreatePersonsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('persons', function (Blueprint $table) {
            $table->integer('id_person', true);
            $table->string('person_type', 5)->comment('tabla: tipo_persona');
            $table->string('person_class', 20)->comment('tabla: clase_persona (separado por comas)');
            $table->string('internal_code', 15);
            $table->string('ruc', 15)->nullable();
            $table->string('document_number', 20)->nullable();
            $table->string('document_type', 5)->nullable();
            $table->string('names', 100)->nullable();
            $table->string('tradename', 100)->nullable();
            $table->string('business_name', 100)->nullable();
            $table->string('last_name_1', 50)->nullable();
            $table->string('last_name_2', 50)->nullable();
            $table->string('address', 200)->nullable();
            $table->integer('id_ubigeo')->nullable();
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
        Schema::dropIfExists('persons');
    }
}
