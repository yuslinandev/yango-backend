# yango-backend
API yango app usando JWT 

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