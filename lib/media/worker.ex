defmodule EvercamMedia.Worker do
  import EvercamMedia.Snapshot
  import EvercamMedia.Schedule

  def start_link(args) do
    IO.puts("Starting camera worker '#{args[:camera_id]}'")
    worker_name = args[:camera_id] |> String.to_atom
    GenServer.start_link(__MODULE__, args, name: worker_name)
  end

  def init(args) do
    Task.start_link(fn -> loop(args) end)
  end

  defp loop(args) do
    if args[:frequent] do
      :timer.sleep(1000)
    else
      :timer.sleep(60_000 + args[:initial_sleep])
      args = Dict.put(args, :initial_sleep, 0)
    end
    if scheduled?(args[:schedule], args[:timezone]) do
      Task.async(fn -> check_camera(args) end) |> Task.await(:infinity)
    end
    loop(args)
  end
end
