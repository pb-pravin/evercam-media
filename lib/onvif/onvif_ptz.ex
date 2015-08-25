defmodule EvercamMedia.ONVIFPTZ do
  alias EvercamMedia.ONVIFClient

  def get_nodes(url, username, password) do
    method = "GetNodes"
    xpath = "/env:Envelope/env:Body/tptz:GetNodesResponse"
    ptz_request(url, method, xpath, username, password)
  end

  def get_configurations(url, username, password) do
    method = "GetConfigurations"
    xpath = "/env:Envelope/env:Body/tptz:GetConfigurationsResponse"
    ptz_request(url, method, xpath, username, password)
  end

  def get_presets(url, username, password, profile_token) do
    method = "GetPresets"
    xpath = "/env:Envelope/env:Body/tptz:GetPresetsResponse"
    parameters = "<ProfileToken>#{profile_token}</ProfileToken>"
    {:ok, response} = ptz_request(url, method, xpath, username, password, parameters)
    presets = response |> Map.get("Preset") |> Enum.filter(&(Map.get(&1, "Name") != nil))
    {:ok, Map.put(%{}, "Presets", presets)}
  end

  def get_status(url, username, password, profile_token) do
    method = "GetStatus"
    xpath = "/env:Envelope/env:Body/tptz:GetStatusResponse"
    parameters = "<ProfileToken>#{profile_token}</ProfileToken>"
    ptz_request(url, method, xpath, username, password, parameters)
  end

  def goto_preset(url, username, password, profile_token, preset_token, speed \\ []) do
    method = "GotoPreset"
    xpath = "/env:Envelope/env:Body/tptz:GotoPresetResponse"
    parameters = "<ProfileToken>#{profile_token}</ProfileToken><PresetToken>#{preset_token}</PresetToken>" <>
      case pan_tilt_zoom_vector speed do
        "" -> ""
        vector -> "<Speed>#{vector}</Speed>"
      end
    ptz_request(url, method, xpath, username, password, parameters)
  end

  def relative_move(url, username, password, profile_token, translation, speed \\ []) do
    method = "RelativeMove"
    xpath = "/env:Envelope/env:Body/tptz:RelativeMoveResponse"
    parameters = "<ProfileToken>#{profile_token}</ProfileToken><Translation>#{pan_tilt_zoom_vector translation}</Translation>" <>
      case pan_tilt_zoom_vector speed do
        "" -> ""
        vector -> "<Speed>#{vector}</Speed>"
      end
    ptz_request(url, method, xpath,username, password, parameters)
  end

  def continuous_move(url, username, password, profile_token, velocity \\ []) do
    method = "ContinuousMove"
    xpath = "/env:Envelope/env:Body/tptz:ContinuousMoveResponse"
    parameters = "<ProfileToken>#{profile_token}</ProfileToken>" <>
      case pan_tilt_zoom_vector velocity do
        "" -> ""
        vector -> "<Velocity>#{vector}</Velocity>"
      end
    ptz_request(url, method, xpath, username, password, parameters)
  end

  def goto_home_position(url, username, password, profile_token, speed \\ []) do
    method = "GotoHomePosition"
    xpath = "/env:Envelope/env:Body/tptz:GotoHomePositionResponse"
    parameters = "<ProfileToken>#{profile_token}</ProfileToken>" <>
      case pan_tilt_zoom_vector speed do
        "" -> ""
        vector  -> "<Speed>#{vector}</Speed>"
      end
    ptz_request(url, method, xpath, username, password, parameters)
  end

  def remove_preset(url, username, password, profile_token, preset_token) do
    method = "RemovePreset"
    xpath = "/env:Envelope/env:Body/tptz:RemovePresetResponse"
    parameters = "<ProfileToken>#{profile_token}</ProfileToken><PresetToken>#{preset_token}</PresetToken>"
    ptz_request(url, method, xpath, username, password, parameters)
  end

  def set_preset(url, username, password, profile_token, preset_name \\ "", preset_token \\ "") do
    method = "SetPreset"
    xpath = "/env:Envelope/env:Body/tptz:SetPresetResponse"
    parameters = "<ProfileToken>#{profile_token}</ProfileToken>" <>
      case preset_name do
        "" -> ""
        _ -> "<PresetName>#{preset_name}</PresetName>"
      end <>
      case preset_token do
        "" -> ""
        _ -> "<PresetToken>#{preset_token}</PresetToken>"
      end
    ptz_request(url, method, xpath, username, password, parameters)
  end

  def set_home_position(url, username, password, profile_token) do
    method = "SetHomePosition"
    xpath = "/env:Envelope/env:Body/tptz:SetHomePositionResponse"
    parameters = "<ProfileToken>#{profile_token}</ProfileToken>"
    ptz_request(url, method, xpath, username, password, parameters)
  end

  def stop(url, username, password, profile_token) do
    method = "Stop"
    xpath = "/env:Envelope/env:Body/tptz:StopResponse"
    parameters = "<ProfileToken>#{profile_token}</ProfileToken>"
    ptz_request(url, method, xpath, username, password, parameters)
  end

  def pan_tilt_zoom_vector(vector) do
    pan_tilt =
      case {vector[:x], vector[:y]}  do
        {nil, _} -> ""
        {_, nil} -> ""
        {x, y}  -> "<PanTilt x=\"#{x}\" y=\"#{y}\" xmlns=\"http://www.onvif.org/ver10/schema\"/>"
      end
    zoom =
      case vector[:zoom] do
        nil -> ""
        zoom  -> "<Zoom x=\"#{zoom}\"  xmlns=\"http://www.onvif.org/ver10/schema\"/>"
      end
    pan_tilt <> zoom
  end

  defp ptz_request(url, method, xpath, username, password, parameters \\ "") do
    ONVIFClient.onvif_call(url, :ptz, method, xpath, username, password, parameters)
  end
end
