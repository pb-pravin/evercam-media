defmodule DeviceManagementTest do
  use ExUnit.Case
  alias EvercamMedia.ONVIFDeviceManagement

  test "get_system_date_and_time method on hikvision camera" do
    {:ok, response} = ONVIFDeviceManagement.get_system_date_and_time("http://149.13.244.32:8100", "admin", "mehcam")

    year = response
    |> Map.get("Date")
    |> Map.get("Year")
    assert year == "2015"
  end

  test "get_device_information method on hikvision camera" do
    {:ok, response} = ONVIFDeviceManagement.get_device_information("http://149.13.244.32:8100", "admin", "mehcam")

    assert Map.get(response, "Manufacturer")  == "HIKVISION"
    assert Map.get(response, "Model") == "DS-2DF7286-A"
    assert Map.get(response, "FirmwareVersion") == "V5.1.8 build 140616"
    assert Map.get(response, "SerialNumber") == "DS-2DF7286-A20140705CCWR471699220B"
    assert Map.get(response, "HardwareId") == "88"
  end

  test "get_network_interfaces method on hikvision camera" do
    {:ok, response} = ONVIFDeviceManagement.get_network_interfaces("http://149.13.244.32:8100", "admin", "mehcam")

    address = response
    |> Map.get("IPv4")
    |> Map.get("Config")
    |> Map.get("Manual")
    |> Map.get("Address")
    assert address == "192.168.1.100"

    hw_address = response
    |> Map.get("Info")
    |> Map.get("HwAddress")
    assert hw_address == "44:19:b6:4b:f1:a2"
  end
end
