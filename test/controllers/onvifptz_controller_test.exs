defmodule EvercamMedia.ONVIFPTZControllerTest do
  use EvercamMedia.ConnCase

  test "GET /onvif/cameras/:camera_id/ptz/presets, gives something" do
    conn = get conn(), "/onvif/cameras/:camera_id/ptz/presets", camera_id: "mobile-mast-test"
    IO.puts inspect json_response(conn, 200) 
  end




end
