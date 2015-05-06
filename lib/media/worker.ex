defmodule EvercamMedia.Worker do
  import EvercamMedia.Snapshot

  def start_link(args) do
    IO.puts("Starting camera worker '#{args[:camera_id]}'")
    worker_name = args[:camera_id] |> String.to_atom
    GenServer.start_link(__MODULE__, args, name: worker_name)
  end

  def init(args) do
    Task.start_link(fn -> loop(args) end)
  end

  defp loop(args) do
    Task.async(fn -> check_camera(args) end)
    if args[:frequent] do
      :timer.sleep 1_000
    else
      :timer.sleep 60_000
    end
    loop(args)
  end
end
