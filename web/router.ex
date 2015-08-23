defmodule EvercamMedia.Router do
  use EvercamMedia.Web, :router

  pipeline :browser do
    plug :accepts, ["html", "json", "jpg"]
    plug :fetch_session
    plug :fetch_flash
  end

  scope "/", EvercamMedia do
    pipe_through :browser

    get "/", PageController, :index

    post "/v1/cameras/test", SnapshotController, :test
    get "/v1/cameras/:id/live/snapshot", SnapshotController, :show
    post "/v1/cameras/:id/recordings/snapshots", SnapshotController, :create

    get "/v1/cameras/:id/ptz/status", ONVIFPTZController, :status
    get "/v1/cameras/:id/ptz/presets", ONVIFPTZController, :presets
    post "/v1/cameras/:id/ptz/home", ONVIFPTZController, :home
    post "/v1/cameras/:id/ptz/home/set", ONVIFPTZController, :sethome
    post "/v1/cameras/:id/ptz/presets/:preset_token", ONVIFPTZController, :setpreset
    post "/v1/cameras/:id/ptz/presets/create/:preset_name", ONVIFPTZController, :createpreset
    post "/v1/cameras/:id/ptz/presets/go/:preset_token", ONVIFPTZController, :gotopreset
    post "/v1/cameras/:id/ptz/continuous/start/:direction", ONVIFPTZController, :continuousmove
    post "/v1/cameras/:id/ptz/continuous/zoom/:mode", ONVIFPTZController, :continuouszoom
    post "/v1/cameras/:id/ptz/continuous/stop", ONVIFPTZController, :stop
    post "/v1/cameras/:id/ptz/relative", ONVIFPTZController, :relativemove
    
    get "/v1/cameras/:id/macaddr", ONVIFDeviceManagementController, :macaddr

    get "/live/:camera_id/index.m3u8", StreamController, :hls
    get "/live/:camera_id/:filename", StreamController, :ts
    get "/on_play", StreamController, :rtmp
  end

  socket "/ws", EvercamMedia do
    channel "cameras:*", SnapshotChannel
  end
end
