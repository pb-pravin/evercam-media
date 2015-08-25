defmodule EvercamMedia.ONVIFDeviceManagement do
  alias EvercamMedia.ONVIFClient

  def get_system_date_and_time(url, username, password) do
    method = "GetSystemDateAndTime"
    xpath = "/env:Envelope/env:Body/tds:GetSystemDateAndTimeResponse/tds:SystemDateAndTime/tt:LocalDateTime"
    device_management_request(url, method, xpath, username, password)
  end

  def get_device_information(url, username, password) do
    method = "GetDeviceInformation"
    xpath = "/env:Envelope/env:Body/tds:GetDeviceInformationResponse"
    device_management_request(url, method, xpath, username, password)
  end

  def get_network_interfaces(url, username, password) do
    method = "GetNetworkInterfaces"
    xpath = "/env:Envelope/env:Body/tds:GetNetworkInterfacesResponse/tds:NetworkInterfaces"
    device_management_request(url, method, xpath, username, password)
  end

  def device_management_request(url, method, xpath,  username, password) do
    ONVIFClient.onvif_call(url, :device, method, xpath, username, password)
  end
end
