defmodule EvercamMedia.ONVIFPTZController do
  use Phoenix.Controller
  alias EvercamMedia.Repo
  alias EvercamMedia.ONVIFPTZ
  require Logger
  plug :action

  def presets(conn, params) do
    camera = Repo.one! Camera.by_exid(params["camera_id"])
    url = Camera.external_url camera
    [username, password] =
      camera 
      |> Camera.auth
      |> String.split ":"
    {:ok, response} = ONVIFPTZ.get_presets(url, username, password)    
    presets_respond(conn, 200, response)
  end

  defp presets_respond(conn, code, response) do
    conn
    |> put_status(code)
    |> put_resp_header("access-control-allow-origin", "*")
    |> json response
  end
   

end
