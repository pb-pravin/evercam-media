defmodule Media.Worker do
  import Media.SnapshotFetch

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

  defp check_camera(args) do
    try do
      response = fetch_snapshot(args[:url], args[:auth])
      check_jpg(response)
      store_image(args[:camera_id], response)
    rescue
      error in [FunctionClauseError] ->
        error_handler(error)
      _error in [HTTPotion.HTTPError] ->
        IO.puts ""
      _error ->
        error_handler(_error)
    end
  end
end
