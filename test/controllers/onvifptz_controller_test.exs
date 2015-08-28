defmodule EvercamMedia.ONVIFPTZControllerTest do
  use EvercamMedia.ConnCase

  test "GET /v1/cameras/:id/ptz/presets, gives something" do
    conn = get conn(), "/v1/cameras/mobile-mast-test/ptz/presets"
    presets = conn
    |> json_response(200)
    |> Map.get("Presets")
    assert presets != nil
  end

  test "GET /v1/cameras/:id/ptz/status, gives something" do
    conn = get conn(), "/v1/cameras/mobile-mast-test/ptz/status"
    error_status = conn
    |> json_response(200)
    |> Map.get("PTZStatus")
    |> Map.get("Error")
    assert error_status == "NO error"
  end

  test "POST /v1/cameras/:id/ptz/relative?left=0&right=10&up=0&down=10&zoom=0 moves right and down" do
    # get home first
    conn = post conn(), "/v1/cameras/mobile-mast-test/ptz/home"
    assert json_response(conn, 200) == "ok"
    # give time to the camera to move
    :timer.sleep(3000)
    conn = get conn(), "/v1/cameras/mobile-mast-test/ptz/status"
    response = json_response(conn, 200)
    x_before = extract_position(response, "x")
    y_before = extract_position(response, "y")
    conn = post(
      conn(),
      "/v1/cameras/mobile-mast-test/ptz/relative",
      %{"left" => "0", "right" => "10", "up" => "0", "down" => "10", "zoom" => "0"}
    )
    assert json_response(conn, 200) == "ok"
    # give time to the camera to move
    :timer.sleep(3000)
    conn = get conn(), "/v1/cameras/mobile-mast-test/ptz/status"
    response = json_response(conn, 200)
    x_after = extract_position(response, "x")
    y_after = extract_position(response, "y")
    assert (x_after - x_before) * 100 |> round == 10
    assert (y_after - y_before) * 100 |> round == 20
  end


  test "POST /v1/cameras/:id/ptz/relative?left=10&right=0&up=10&down=0&zoom=0 moves left and up" do
    # get home first
    conn = post conn(), "/v1/cameras/mobile-mast-test/ptz/home"
    assert json_response(conn, 200) == "ok"
    # give time to the camera to move
    :timer.sleep(3000)
    conn = get conn(), "/v1/cameras/mobile-mast-test/ptz/status"
    response = json_response(conn, 200)
    x_before = extract_position(response, "x")
    y_before = extract_position(response, "y")
    conn = post(
      conn(),
      "/v1/cameras/mobile-mast-test/ptz/relative",
      %{"left" => "10", "right" => "0", "up" => "10", "down" => "0", "zoom" => "0"}
    )
    assert json_response(conn, 200) == "ok"
    # give time to the camera to move
    :timer.sleep(3000)
    conn = get conn(), "/v1/cameras/mobile-mast-test/ptz/status"
    response = json_response(conn, 200)
    x_after = extract_position(response, "x")
    y_after = extract_position(response, "y")
    assert x_before == -1.0
    assert x_after == 0.9
    assert (y_after - y_before) * 100 |> round == -20
  end

  defp extract_position(map, coord) do
    map
    |> Map.get("PTZStatus")
    |> Map.get("Position")
    |> Map.get("PanTilt")
    |> Map.get(coord)
    |> String.to_float
  end
end
