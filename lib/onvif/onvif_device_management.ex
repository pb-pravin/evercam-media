defmodule EvercamMedia.ONVIFDeviceManagement do
  alias EvercamMedia.ONVIFClient

  def get_system_date_and_time(url, username, password) do
    device_management_request(url, "GetSystemDateAndTime", 
                              "/env:Envelope/env:Body/tds:GetSystemDateAndTimeResponse/tds:SystemDateAndTime/tt:LocalDateTime", 
                              username, password)
  end

  def get_device_information(url, username, password) do
    device_management_request(url, "GetDeviceInformation", 
                              "/env:Envelope/env:Body/tds:GetDeviceInformationResponse", 
                              username, password)
  end

  def get_network_interfaces(url, username, password) do
    device_management_request(url, "GetNetworkInterfaces",
                              "/env:Envelope/env:Body/tds:GetNetworkInterfacesResponse/tds:NetworkInterfaces", 
                              username, password)
  end

  def device_management_request(url, method, xpath,  username, password) do
    ONVIFClient.onvif_call(url, :device, method, xpath, username, password)
  end
end
