defmodule EvercamMedia.ONVIFPTZControllerTest do
  use EvercamMedia.ConnCase

  test "GET /onvif/cameras/:camera_id/ptz/presets, gives something" do
    conn = get conn(), "/onvif/cameras/mobile-mast-test/ptz/presets"
    assert inspect json_response(conn, 200) =~ "Back Main Yard" 
  end

end
