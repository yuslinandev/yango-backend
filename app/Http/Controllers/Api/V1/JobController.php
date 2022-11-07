<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\Employee_jobs;
use Illuminate\Http\Request;
use App\Http\Resources\V1\JobCollection; // llamar al recurso
use Symfony\Component\HttpFoundation\Response; // lista de codigos de estado

class JobController extends Controller
{
    /**
     * Display a listing custom of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function list(Request $request)
    {
        // Obtener data de la url, ej:
        http://127.0.0.1:8000/api/v1/job_list?page=1&toShow=5&sortField=name&sort=DESC

        // Valores por defecto
        // page por default
        $size =  $request->input('size') ?? 10;
        $orderField = $request->input('orderField') ?? 'name';
        $order = $request->input('order') ?? 'asc';
        $searchField = $request->input('searchField') ?? 'name';
        $search = $request->input('search') ?? '';

        if($search != ""){
            $job = Employee_jobs::where( 'name', 'LIKE', '%' . $search . '%' )
                ->where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }else{
            $job = Employee_jobs::where('state', '<>', 'E')->orderBy($orderField, $order)->paginate ($size);
        }

        return response()->json(
            new JobCollection( $job )
        , Response::HTTP_OK);

    }
    /**
     * Display a listing of the resource.
     *
     * @return \Illuminate\Http\Response
     */
    public function index()
    {
        // Para cambiar los datos a mostrar en la coleccion,
        // ver archivo de JobResource
        return JobResource::collection(Employee_jobs::latest()->paginate());
    }

    /**
     * Store a newly created resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function store(Request $request)
    {
        $this->validateJob($request);

        //dd($request->all());

        $job = Employee_jobs::create([
            'name' => $request->name,

            'description' => $request -> description,
            'state' => $request->state,
            'user_creation' => auth()->user()->id
        ]);

        $jobInserted = Employee_jobs::find($job->id_employee_job, ['id_employee_job AS id','name',  'description','state']);

        return response()->json([
            'message' => 'Job Add',
            'data' => $jobInserted
        ], Response::HTTP_OK);
    }

    public function validateJob(Request $request)
    {
        return $request->validate([
            'name' => 'required'
        ]);
    }

    /**
     * Display the specified resource.
     *
     * @param  \App\Models\Job  $job
     * @return \Illuminate\Http\Response
     */
    public function show(Job $job)
    {
        return new JobResource($job);
    }

    /**
     * Update the specified resource in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Job  $job
     * @return \Illuminate\Http\Response
     */
    public function update(Request $request)
    {
        $id = $request->id;

        $this->validateJob($request);

        //dd($request->all());

        // $job->update( $request->all() ); Captura y guarda todos valores enviados desde el front

        // Aqui podemos personalizar los valore a guardar
         $state = $request->state;
                if (strval($state) ==  true ) {
                      $state = "A" ;
                } else
                {
                     $state = "I" ;
                }

        $job = Employee_jobs::findOrFail($id)->update([
            'name' => $request->name,
            'description' => $request->description,
            'user_edit' => auth()->user()->id,
            'state' => $state
        ]);

        $jobUpdated = Employee_jobs::find($id, ['id_employee_job AS id','name',  'description','state']);

        return response()->json([
            'message' => 'Job Update',
            'data' => $jobUpdated
        ], Response::HTTP_OK);

    }

    /**
     * Remove the specified resource from storage.
     *
     * @param  \App\Models\Job  $job
     * @return \Illuminate\Http\Response
     */
    public function destroy(Job $job)
    {
        $job->delete();

        return response()->json([
            'message' => 'Job Destroyed'
        ], Response::HTTP_ACCEPTED); // de la clase de codigos de estado
    }

    /**
     * Logical delete register
     *
     */
    public function delete($id)
    {
        Employee_jobs::findOrFail($id)->update([
            'state' => "E"
        ]);

        return response()->json([
            'message' => 'Job Deleted',
            'data' => 'true'
        ], Response::HTTP_ACCEPTED);
    }
}
