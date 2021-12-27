<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     *
     * @return void
     */
    public function run()
    {
        // \App\Models\User::factory(10)->create();
        // crear un usuario de prueba
        \App\Models\User::create([
            'name' => 'Jesus Linan',
            'email' => 'jesusvld@gmail.com',
            'password' => bcrypt('doko2021')
        ]);
 
        // crear 20 posts de prueba
        \App\Models\Brand::factory(150)->create();

    }
}
