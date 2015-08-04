defmodule EvercamMedia.Endpoint do
  use Phoenix.Endpoint, otp_app: :evercam_media

  # Serve at "/" the given assets from "priv/static" directory
  plug Plug.Static,
    at: "/", from: :evercam_media,
    only: ~w(css images js favicon.ico robots.txt)

  plug Plug.Logger

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_media_key",
    signing_salt: "sZRQyVW1"

  plug EvercamMedia.Router
end
