defmodule EvercamMedia.Worker.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    unless Application.get_env(:evercam_media, :skip_camera_workers) do
      Task.start_link(&EvercamMedia.Worker.Supervisor.initiate_workers/0)
    end

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
    # |> Enum.filter(&(Camera.recording? &1))
    |> Enum.map(&(start_camera_worker &1))
  end

  def start_camera_worker(camera) do
    camera = EvercamMedia.Repo.preload camera, :cloud_recordings
    url = "#{Camera.external_url(camera)}#{Camera.res_url(camera, "jpg")}"
    auth = Camera.auth(camera)
    frequent = Camera.recording?(camera)
    sleep = :crypto.rand_uniform(1, 60) * 1000

    unless String.length(url) == 0 do
      EvercamMedia.Worker.Supervisor.start_child([
        camera_id: camera.exid,
        schedule: Camera.schedule(camera),
        timezone: camera.timezone,
        url: url,
        auth: auth,
        frequent: frequent,
        initial_sleep: sleep
      ])
    end
  end
end
