defmodule EvercamMedia.ONVIFPTZController do
  use Phoenix.Controller
  alias EvercamMedia.Repo
  alias EvercamMedia.ONVIFPTZ
  require Logger
  plug :action

  def presets(conn, params) do
    [url, username, password] = get_camera_info(params["camera_id"])
    {:ok, response} = ONVIFPTZ.get_presets(url, username, password, "Profile_1")    
    default_respond(conn, 200, response)
  end

  def stop(conn, params) do
    [url, username, password] = get_camera_info(params["camera_id"])
    {:ok, response} = ONVIFPTZ.stop(url, username, password, "Profile_1")    
    default_respond(conn, 200, response)
  end

  def home(conn, params) do
    [url, username, password] = get_camera_info(params["camera_id"])
    {:ok, response} = ONVIFPTZ.goto_home_position(url, username, password, "Profile_1")    
    default_respond(conn, 200, response)
  end

  def sethome(conn, params) do
    [url, username, password] = get_camera_info(params["camera_id"])
    {:ok, response} = ONVIFPTZ.set_home_position(url, username, password, "Profile_1")    
    default_respond(conn, 200, response)
  end

   def gotopreset(conn, params) do
    [url, username, password] = get_camera_info(params["camera_id"])
    {:ok, response} = ONVIFPTZ.goto_preset(url, username, password, 
                                           "Profile_1", params["preset_token"])    
    default_respond(conn, 200, response)
  end

  def setpreset(conn, params) do
    [url, username, password] = get_camera_info(params["camera_id"])
    {:ok, response} = ONVIFPTZ.set_preset(url, username, 
                                                 password, "Profile_1",
                                                 params["preset_token"],
                                                 "Test")    
    default_respond(conn, 200, response)
  end

  defp default_respond(conn, code, response) do
    conn
    |> put_status(code)
    |> put_resp_header("access-control-allow-origin", "*")
    |> json response
  end
   

  defp get_camera_info(camera_id) do
    camera = Repo.one! Camera.by_exid(camera_id)
    url = Camera.external_url camera
    [username, password] =
      camera 
      |> Camera.auth
      |> String.split ":"
    [url, username, password]
  end

end
