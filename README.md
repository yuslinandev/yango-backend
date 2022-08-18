# yango-backend

API yango app usando JWT 

Para configurar el entorno
1. Instalar Composer
    - https://getcomposer.org/download/
3. Instalar Laravel
    - composer global require laravel/installer
5. Instalar las dependencias del proyecto
    - composer install
6. Instalar las llaves
    - php artisan key:generate 
    - php artisan jwt:secret 
    - php artisan cache:clear 
    - php artisan config:clear
8. Iniciar el proyecto
    - php artisan serve

A probar nuestra api en postman o insomnia. 

http://127.0.0.1:8000/api/login

{
    "email" : "jesusvld@gmail.com",
    "password" : "doko2021"
}

No deberá retornar un token, que podremos usar para realizar nuestra peticiones.

Probar estos endpoint con el token obtenido:

http://127.0.0.1:8000/api/v1/brand

http://127.0.0.1:8000/api/v1/brand/1

Luego de una actualizacion en repo, probar el comando:

php artisan migrate:fresh --seed
