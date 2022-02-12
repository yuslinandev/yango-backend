<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateFormulaDetailsTable extends Migration
{
    /**
     * Run the migrations.
     *
     * @return void
     */
    public function up()
    {
        Schema::create('formula_details', function (Blueprint $table) {
            $table->integer('id_formula_detail', true);
            $table->integer('id_formula');
            $table->integer('id_product');
            $table->integer('id_unit');
            $table->decimal('quantity', 14, 4);
            $table->string('commentary', 200)->nullable();
            $table->string('state', 5);
        });
    }

    /**
     * Reverse the migrations.
     *
     * @return void
     */
    public function down()
    {
        Schema::dropIfExists('formula_details');
    }
}
