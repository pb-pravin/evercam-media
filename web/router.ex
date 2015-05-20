defmodule EvercamMedia.Router do
  use EvercamMedia.Web, :router

  pipeline :browser do
    plug :accepts, ["html", "json", "jpg"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  scope "/", EvercamMedia do
    pipe_through :browser

    get "/", PageController, :index

    get "/v1/cameras/:id/live/snapshot", SnapshotController, :show

    get "/on_play", StreamController, :show
  end

  socket "/ws", EvercamMedia do
    channel "cameras:*", SnapshotChannel
  end
end
