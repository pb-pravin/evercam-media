defmodule EvercamMedia.ONVIFPTZControllerTest do
  use EvercamMedia.ConnCase

  test "GET /v1/cameras/:id/ptz/presets, gives something" do
    conn = get conn(), "/v1/cameras/mobile-mast-test/ptz/presets"
    assert json_response(conn, 200) 
           |> Map.get("Presets") != nil
  end

end
