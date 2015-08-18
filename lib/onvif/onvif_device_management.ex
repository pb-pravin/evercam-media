defmodule EvercamMedia.ONVIFDeviceManagement do
  alias EvercamMedia.ONVIFClient

  def get_system_date_and_time(host, port, username, password) do
    device_management_request(host, port,"GetSystemDateAndTime", 
                              "/env:Envelope/env:Body/tds:GetSystemDateAndTimeResponse/tds:SystemDateAndTime/tt:LocalDateTime", 
                              username, password)
  end

  def get_device_information(host, port, username, password) do
    device_management_request(host, port,"GetDeviceInformation", 
                              "/env:Envelope/env:Body/tds:GetDeviceInformationResponse", 
                              username, password)
  end

  def get_network_interfaces(host, port, username, password) do
    device_management_request(host, port,"GetNetworkInterfaces",
                              "/env:Envelope/env:Body/tds:GetNetworkInterfacesResponse/tds:NetworkInterfaces", 
                              username, password)
  end

  def device_management_request(host, port, method, xpath,  username, password) do
    ONVIFClient.onvif_call(host, port, :device, method, xpath, username, password)
  end
end
