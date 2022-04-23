<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateConfigsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('configs', function (Blueprint $table) {
            $table->integer('id_config', true);
            $table->string('table', 20);
            $table->string('code', 20);
            $table->string('field', 50)->nullable();
            $table->string('alp_num_value', 50)->nullable();
            $table->decimal('num_value', 14, 4)->nullable();
            $table->string('state', 5)->default('A');
            $table->dateTime('validity_date_start', 6)->nullable();
            $table->dateTime('validity_date_end', 6)->nullable();
            $table->integer('order_number')->nullable();
            $table->timestamps();
            
            $table->index(['table', 'code'], 'idx_config_1');
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('configs');
    }
}
