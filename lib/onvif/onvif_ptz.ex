defmodule EvercamMedia.ONVIFPTZ do

  alias EvercamMedia.ONVIFClient

  def get_nodes(host, port, username, password) do
    ptz_request(host, port,"GetNodes", 
                "/env:Envelope/env:Body/tptz:GetNodesResponse", username, password)
   end

  def get_configurations(host, port, username, password) do
    ptz_request(host, port,"GetConfigurations", 
                "/env:Envelope/env:Body/tptz:GetConfigurationsResponse", username, password)
  end

  def get_presets(host, port, username, password, profile_token) do
    {:ok, response} = ptz_request(host, port,"GetPresets", 
                                  "/env:Envelope/env:Body/tptz:GetPresetsResponse", 
                                  username, password,
                                  "<ProfileToken>#{profile_token}</ProfileToken>")
    {:ok, Map.put(%{}, 
                  "Presets",
                  response
		  |>  Poison.Parser.parse!
                  |>  Map.get("Preset")
                  |>  Enum.filter(&(Map.get(&1, "Name") != nil))
          )
          |> Poison.Encoder.encode(nil)
          |> IO.iodata_to_binary}
  end

  def get_status(host, port, username, password, profile_token) do
    ptz_request(host, port,"GetStatus", 
               "/env:Envelope/env:Body/tptz:GetStatusResponse",
               username, password,
               "<ProfileToken>#{profile_token}</ProfileToken>")
  end


  def goto_preset(host, port, username, password, profile_token, preset_token, speed \\ []) do
    ptz_request(host, port,"GotoPreset", "/env:Envelope/env:Body/tptz:GotoPresetResponse", 
                username, password,
                "<ProfileToken>#{profile_token}</ProfileToken>
                 <PresetToken>#{preset_token}</PresetToken>"
		 <> case pan_tilt_zoom_vector speed do
                      "" -> ""
		      vector -> "<Speed>#{vector}</Speed>"
                    end)
  end
 
  def relative_move(host, port, username, password, profile_token, translation, speed \\ []) do
    ptz_request(host, port, "RelativeMove", 
                "/env:Envelope/env:Body/tptz:GotoPresetResponse",username, password,
                                  "<ProfileToken>#{profile_token}</ProfileToken>
                                  <Translation>#{pan_tilt_zoom_vector translation}</Translation>"
		                              <> case pan_tilt_zoom_vector speed do
                                                   "" -> ""
		                                   vector -> "<Speed>#{vector}</Speed>"
	                                         end)
  end
 
  def stop(host, port, username, password, profile_token) do
    ptz_request(host, port,"Stop", 
                "/env:Envelope/env:Body/tptz:StopResponse", 
                username, password,
                "<ProfileToken>#{profile_token}</ProfileToken>")
  end


  def pan_tilt_zoom_vector(vector) do
    pan_tilt = case {vector[:x], vector[:y]}  do
                {nil,_} -> ""
                {_, nil} -> ""
                {x,y}  -> "<PanTilt x=\"#{x}\" y=\"#{y}\" xmlns=\"http://www.onvif.org/ver10/schema\"/>"
	      end
    zoom = case vector[:zoom] do
             nil -> ""									 
             zoom  -> "<Zoom x=\"#{zoom}\"  xmlns=\"http://www.onvif.org/ver10/schema\"/>"
           end
    pan_tilt <> zoom
  end

  defp ptz_request(host, port, method, xpath, username, password, parameters \\ "") do
    ONVIFClient.onvif_call(host, port, :ptz, method, xpath, username, password, parameters) 
  end
end
