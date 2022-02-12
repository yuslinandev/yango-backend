<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateEmployeesTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('employees', function (Blueprint $table) {
            $table->integer('id_employee', true);
            $table->string('document_number', 20)->nullable();
            $table->string('document_type', 5)->nullable();
            $table->string('names', 100);
            $table->string('last_name_1', 50);
            $table->string('last_name_2', 50)->nullable();
            $table->string('address', 200)->nullable();
            $table->integer('id_ubigeo')->nullable();
            $table->smallInteger('id_employee_area')->nullable();
            $table->smallInteger('id_employee_job')->nullable();
            $table->integer('id_warehouse_assigned')->nullable();
            $table->integer('id_local_assigned')->nullable();
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
        Schema::dropIfExists('employees');
    }
}
