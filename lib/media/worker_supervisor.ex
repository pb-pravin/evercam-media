defmodule Media.Worker.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_) do
    supervise(
      [worker(Media.Worker, [],[restart: :permanent, shutdown: :infinity])],
      strategy: :simple_one_for_one,
      max_restarts: 1_000_000,
      max_seconds: 1_000_000
    )
  end

  def start_child(args) do
    Supervisor.start_child(__MODULE__, [args])
  end
end
