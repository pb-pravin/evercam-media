defmodule EvercamMedia.Worker.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    Task.async(&EvercamMedia.Worker.Supervisor.initiate_workers/0)

    supervise(
      [worker(EvercamMedia.Worker, [], [restart: :permanent, shutdown: :infinity])],
      strategy: :simple_one_for_one,
      max_restarts: 1_000_000,
      max_seconds: 1_000_000
    )
  end

  def start_child(args) do
    Supervisor.start_child(__MODULE__, [args])
  end

  def initiate_workers do
    EvercamMedia.Repo.all(Camera)
    |> Enum.filter(&(Camera.recording? &1))
    |> Enum.map(&(start_camera_worker &1))
  end

  def start_camera_worker(camera) do
    url = "#{Camera.external_url(camera)}#{Camera.res_url(camera, "jpg")}"
    auth = Camera.auth(camera)
    frequent = Camera.recording?(camera)

    unless String.length(url) == 0 do
      EvercamMedia.Worker.Supervisor.start_child(
        [camera_id: camera.exid, url: url, auth: auth, frequent: frequent]
      )
    end
  end
end
