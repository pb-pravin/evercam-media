defmodule EvercamMedia.ONVIFMedia do
  alias EvercamMedia.ONVIFClient

  def get_profiles(host, port, username, password) do
    media_request(host, port,"GetProfiles",
                  "/env:Envelope/env:Body/trt:GetProfilesResponse", username, password)
  end

 defp media_request(host, port, method, xpath, username, password) do
   ONVIFClient.onvif_call(host, port, :media, method, xpath, username, password) 
 end
end





