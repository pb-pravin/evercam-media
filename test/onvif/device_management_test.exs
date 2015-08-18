defmodule DeviceManagementTest do
  use ExUnit.Case
  alias EvercamMedia.ONVIFDeviceManagement
  
  test "get_system_date_and_time method on hikvision camera" do
    {:ok, response} = ONVIFDeviceManagement.get_system_date_and_time("149.13.244.32", "8100", "admin", "mehcam")
    assert Poison.Parser.parse!(response)
             |> Map.get("Date")
             |> Map.get("Year") == "2015"
  end   

 test "get_device_information method on hikvision camera" do
    {:ok, response} = ONVIFDeviceManagement.get_device_information("149.13.244.32", "8100", "admin", "mehcam")
    result_map = Poison.Parser.parse!(response)

    assert Map.get(result_map, "Manufacturer")  == "HIKVISION"
    assert Map.get(result_map, "Model") == "DS-2DF7286-A"
    assert Map.get(result_map, "FirmwareVersion") == "V5.1.8 build 140616"
    assert Map.get(result_map, "SerialNumber") == "DS-2DF7286-A20140705CCWR471699220B"
    assert Map.get(result_map, "HardwareId") == "88"

 end   

 test "get_network_interfaces method on hikvision camera" do
   {:ok, response} = ONVIFDeviceManagement.get_network_interfaces("149.13.244.32", "8100", "admin", "mehcam")
   result_map = Poison.Parser.parse!(response)
   assert result_map
          |> Map.get("IPv4")
          |> Map.get("Config")
          |> Map.get("Manual")
          |> Map.get("Address") == "192.168.1.100"
   assert result_map
          |> Map.get("Info")
          |> Map.get("HwAddress") == "44:19:b6:4b:f1:a2"

  end   
end

