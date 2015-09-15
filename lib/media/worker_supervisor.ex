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
      [worker(EvercamMedia.Worker, [], [restart: :transient, shutdown: :infinity])],
      strategy: :simple_one_for_one,
      max_restarts: 1_000_000,
      max_seconds: 1_000_000
    )
  end

  def start_child(args) do
    Supervisor.start_child(__MODULE__, [args])
  end

  def initiate_workers do
    Camera
    |> EvercamMedia.Repo.all([timeout: 15000])
    |> Enum.with_index # Useful for debugging how many camera workers have been started.
    |> Enum.map(&(start_camera_worker &1))
  end

  def start_camera_worker(camera_with_index) do
    {camera, index } = camera_with_index
    camera = EvercamMedia.Repo.preload camera, :cloud_recordings
    url = "#{Camera.external_url(camera)}#{Camera.res_url(camera, "jpg")}"
    parsed_uri = URI.parse url
    auth = Camera.auth(camera)
    vendor_exid = Camera.get_vendor_exid_by_camera_exid(camera.exid)
    sleep = Camera.sleep(camera)
    initial_sleep = Camera.initial_sleep(camera)

    unless parsed_uri.host == nil do
      EvercamMedia.Worker.Supervisor.start_child([
        index: index + 1,
        camera_id: camera.id,
        camera_exid: camera.exid,
        vendor_exid: vendor_exid,
        schedule: Camera.schedule(camera),
        timezone: camera.timezone,
        url: url,
        auth: auth,
        sleep: sleep,
        initial_sleep: initial_sleep
      ])
    end
  end
end
