defmodule EvercamMedia.ONVIFMedia do
  alias EvercamMedia.ONVIFClient

  def get_profiles(url, username, password) do
    media_request(url,"GetProfiles",
                  "/env:Envelope/env:Body/trt:GetProfilesResponse", username, password)
  end

 defp media_request(url, method, xpath, username, password) do
   ONVIFClient.onvif_call(url, :media, method, xpath, username, password) 
 end
end





