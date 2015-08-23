defmodule PTZTest do
  use ExUnit.Case
  alias EvercamMedia.ONVIFPTZ
  
  test "get_nodes method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.get_nodes("http://149.13.244.32:8100", "admin", "mehcam")
    assert response 
           |> Map.get("PTZNode")
           |> Map.get("Name") == "PTZNODE"
    
    assert response 
           |> Map.get("PTZNode")
           |> Map.get("token") == "PTZNODETOKEN"
   end 

  test "get_configurations method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.get_configurations("http://149.13.244.32:8100", "admin", "mehcam")
    assert response
           |> Map.get("PTZConfiguration")
           |> Map.get("Name") == "PTZ"
    assert response
           |> Map.get("PTZConfiguration")
           |> Map.get("NodeToken") == "PTZNODETOKEN"
  end 

  test "get_presets method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.get_presets("http://149.13.244.32:8100", "admin", "mehcam", "Profile_1")
    [first_preset | _] = 
      response
      |> Map.get("Presets")
    assert first_preset 
           |> Map.get("Name") == "Back Main Yard"
    assert first_preset
           |> Map.get("token") == "1"
  end   

  test "goto_preset method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.goto_preset("http://149.13.244.32:8100", "admin", "mehcam", "Profile_1", "6")
    assert response == :ok
  end   

  test "set_preset and remove_preset method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.set_preset("http://149.13.244.32:8100", "admin", "mehcam", "Profile_1")
	  preset_token = response |> Map.get("PresetToken")
    {:ok, response} = ONVIFPTZ.remove_preset("http://149.13.244.32:8100", "admin", "mehcam", "Profile_1", preset_token)
	  assert response = :ok
  end

  test "set_home_position method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.set_home_position("http://149.13.244.32:8100", "admin", "mehcam", "Profile_1")
	  assert response == :ok
  end

  test "goto_home_position method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.goto_home_position("http://149.13.244.32:8100", "admin", "mehcam", "Profile_1")
	  assert response == :ok
  end   

  
  test "stop method on hikvision camera" do
    {:ok, response} = ONVIFPTZ.stop("http://149.13.244.32:8100", "admin", "mehcam", "Profile_1")
    assert response == :ok
  end

  test "pan_tilt coordinates available" do
    response = ONVIFPTZ.pan_tilt_zoom_vector [x: 0.5671, y: 0.9919]
    assert String.contains? response, "PanTilt"
    assert not String.contains? response, "Zoom"
  end

  test "pan_tilt coordinates and zoom available" do
    response = ONVIFPTZ.pan_tilt_zoom_vector [x: 0.5671, y: 0.9919, zoom: 1.0]
    assert String.contains? response, "Zoom"
    assert String.contains? response, "PanTilt" 
  end

  test "pan_tilt coordinates available broken but zoom ok" do
    response = ONVIFPTZ.pan_tilt_zoom_vector [x: 0.5671, zoom: 0.9919]
    assert String.contains? response, "Zoom"
    assert not String.contains? response, "PanTilt"
  end

  test "pan_tilt_zoom only zoom available" do
    response = ONVIFPTZ.pan_tilt_zoom_vector [zoom: 0.5671]
    assert String.contains? response, "Zoom"
    assert not String.contains? response, "PanTilt"
  end

  test "pan_tilt_zoom empty" do
    response = ONVIFPTZ.pan_tilt_zoom_vector []
    assert not String.contains? response, "Zoom"
    assert not String.contains? response, "PanTilt" 
  end

end

