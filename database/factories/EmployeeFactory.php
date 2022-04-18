<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

class EmployeeFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array
     */
    public function definition()
    {
        return [
            'document_number' => $this->faker->randomNumber($nbDigits = NULL, $strict = false),
            'names' => $this->faker->name,
            'last_name_1' => $this->faker->lastName,
            'address' => $this->faker->address,
            'user_creation' => 1
        ];
    }
}
