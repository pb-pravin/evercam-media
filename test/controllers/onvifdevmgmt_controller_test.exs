defmodule EvercamMedia.ONVIFDeviceManagementControllerTest do
  use EvercamMedia.ConnCase

  test "GET /onvif/cameras/:camera_id/macaddr, returns MAC address" do
    conn = get conn(), "/onvif/cameras/mobile-mast-test/macaddr"
    assert (json_response(conn, 200) |> Map.get("mac_address")) == "44:19:b6:4b:f1:a2"
  end

end
