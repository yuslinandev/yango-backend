<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
    <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <title>Laravel</title>

        <!-- Fonts -->
        <link href="https://fonts.googleapis.com/css2?family=Nunito:wght@400;600;700&display=swap" rel="stylesheet">

        <!-- Styles -->
        <style>
            body {
                font-family: 'Nunito', sans-serif;
            }
            .container{
                margin:0 auto;
                max-width:1040px;
            }
            .grid{
                display:grid;
                gap:10px 10px;
                grid-template-columns: repeat(3, 1fr);
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>Brands</h1>

            <div class="grid">
            @foreach($brands as $brand)
                <div class="col-md-4">
                    <h3 class="post-title">{{ $brand->name }}</h3>
                    <p class="post-excerpt">{{ $brand->description }}</p>
                       
                </div>
            @endforeach
            </div>

        </div>
    </body>
</html>
