defmodule Media.Router do
  use Phoenix.Router

  pipeline :browser do
    plug :accepts, ["html", "json", "jpg"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", Media do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index

    get "/v1/cameras/:id/live/snapshot", SnapshotController, :show
  end

  # Other scopes may use custom stacks.
  # scope "/api", Media do
  #   pipe_through :api
  # end
end
