defmodule EvercamMedia.ONVIFDeviceManagementController do
  use Phoenix.Controller
  alias EvercamMedia.Repo
  alias EvercamMedia.ONVIFDeviceManagement
  require Logger
  plug :action

  def macaddr(conn, params) do
    camera = Repo.one! Camera.by_exid(params["camera_id"])
    url = Camera.external_url camera
    [username, password] =
      camera 
      |> Camera.auth
      |> String.split ":"
    {:ok, response} = ONVIFDeviceManagement.get_network_interfaces(url, username, password) 
    mac_address = response 
                  |> Map.get("Info")
                  |> Map.get("HwAddress")     
    macaddr_respond(conn, 200, mac_address)
  end

  defp macaddr_respond(conn, code, mac_address) do
    conn
    |> put_status(code) 
    |> put_resp_header("access-control-allow-origin", "*")
    |> json %{mac_address: mac_address}
  end
end
