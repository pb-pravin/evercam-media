defmodule EvercamMedia.ONVIFMedia do
  alias EvercamMedia.ONVIFClient

  def get_profiles(url, username, password) do
    method = "GetProfiles"
    xpath = "/env:Envelope/env:Body/trt:GetProfilesResponse"
    media_request(url, method, xpath, username, password)
  end

  defp media_request(url, method, xpath, username, password) do
    ONVIFClient.onvif_call(url, :media, method, xpath, username, password)
  end
end
