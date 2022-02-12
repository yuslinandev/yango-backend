<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUbigeosTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('ubigeos', function (Blueprint $table) {
            $table->integer('id_ubigeo', true);
            $table->string('code', 10)->nullable();
            $table->string('name', 50)->nullable();
            $table->string('state', 5)->nullable();
            $table->char('type', 1)->nullable()->comment('D=Departamento; P=Provincia; I=Distrito');
            $table->integer('id_ubigeo_base')->nullable();
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('ubigeos');
    }
}
