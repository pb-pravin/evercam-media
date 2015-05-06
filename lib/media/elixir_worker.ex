defmodule ElixirWorker do
  def perform(camera_id, url, auth, frequent) do
    worker_name = camera_id |> String.to_atom
    unless Process.whereis(worker_name) do
      EvercamMedia.Worker.Supervisor.start_child(
        [camera_id: camera_id, url: url, auth: auth, frequent: frequent]
      )
    end
  end
end
