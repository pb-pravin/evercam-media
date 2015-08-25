defmodule EvercamMedia.ONVIFPTZController do
  use Phoenix.Controller
  alias EvercamMedia.Repo
  alias EvercamMedia.ONVIFPTZ
  require Logger
  plug :action

  def status(conn, params) do
    [url, username, password] = get_camera_info(params["id"])
    {:ok, response} = ONVIFPTZ.get_status(url, username, password, "Profile_1")
    default_respond(conn, 200, response)
  end

  def presets(conn, params) do
    [url, username, password] = get_camera_info(params["id"])
    {:ok, response} = ONVIFPTZ.get_presets(url, username, password, "Profile_1")
    default_respond(conn, 200, response)
  end

  def stop(conn, params) do
    [url, username, password] = get_camera_info(params["id"])
    {:ok, response} = ONVIFPTZ.stop(url, username, password, "Profile_1")
    default_respond(conn, 200, response)
  end

  def home(conn, params) do
    [url, username, password] = get_camera_info(params["id"])
    {:ok, response} = ONVIFPTZ.goto_home_position(url, username, password, "Profile_1")
    default_respond(conn, 200, response)
  end

  def sethome(conn, params) do
    [url, username, password] = get_camera_info(params["id"])
    {:ok, response} = ONVIFPTZ.set_home_position(url, username, password, "Profile_1")
    default_respond(conn, 200, response)
  end

  def gotopreset(conn, params) do
    [url, username, password] = get_camera_info(params["id"])
    {:ok, response} = ONVIFPTZ.goto_preset(url, username, password, "Profile_1", params["preset_token"])
    default_respond(conn, 200, response)
  end

  def setpreset(conn, params) do
    [url, username, password] = get_camera_info(params["id"])
    {:ok, response} = ONVIFPTZ.set_preset(url, username, password, "Profile_1", "", params["preset_token"])
    default_respond(conn, 200, response)
  end

  def createpreset(conn, params) do
    [url, username, password] = get_camera_info(params["id"])
    {:ok, response} = ONVIFPTZ.set_preset(url, username, password, "Profile_1", params["preset_name"])
    default_respond(conn, 200, response)
  end

  def continuousmove(conn, params) do
    [url, username, password] = get_camera_info(params["id"])
    velocity =
      case params["direction"] do
        "left" -> [x: -0.1, y: 0.0]
        "right" -> [x: 0.1, y: 0.0]
        "up" -> [x: 0.0, y: 0.1]
        "down" -> [x: 0.0, y: -0.1]
        _ -> [x: 0.0, y: 0.0]
      end
    {:ok, response} = ONVIFPTZ.continuous_move(url, username, password, "Profile_1", velocity)
    default_respond(conn, 200, response)
  end

  def continuouszoom(conn, params) do
    [url, username, password] = get_camera_info(params["id"])
    velocity =
      case params["mode"] do
        "in" -> [zoom: 0.01]
        "out" -> [zoom: -0.01]
        _ -> [zoom: 0.0]
      end
    {:ok, response} = ONVIFPTZ.continuous_move(url, username, password, "Profile_1", velocity)
    default_respond(conn, 200, response)
  end

  def relativemove(conn, params) do
    [url, username, password] = get_camera_info(params["id"])
    x = max(Map.get(params, "left", "0"), Map.get(params, "right","0")) |> String.to_integer
    y = max(Map.get(params, "up", "0"), Map.get(params, "down","0")) |> String.to_integer
    zoom = Map.get(params, "zoom", "0") |> String.to_integer
    # If x value comes from "left" parameter make it negative
    x = if Map.get(params, "left") == nil do x else -x end
    # If y value comes from down make it negative
    y = if Map.get(params, "up") == nil do y else -y end
    {:ok, response} = ONVIFPTZ.relative_move(
      url, username,
      password, "Profile_1",
      [x: x / 100.0, y: y / 100.0, zoom: zoom / 100.0]
    )
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
    [username, password] = camera
    |> Camera.auth
    |> String.split ":"
    [url, username, password]
  end
end
