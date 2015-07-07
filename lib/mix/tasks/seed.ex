defmodule Mix.Tasks.Evercam.Seed do
  use Mix.Task
  alias EvercamMedia.Repo

  def run(_args) do
    Logger.configure(level: :error)

    Repo.start_link

    country = Repo.insert %Country{iso3166_a2: "ad", name: "Andorra"}

    user = Repo.insert %User{username: "dev", password: "dev", firstname: "Awesome", lastname: "Dev", email: "dev@localhost", country_id: country.id}

    Repo.insert %Camera{name: "Hikvision Devcam", exid: "hikvision_devcam", owner_id: user.id, is_public: false, config: %{"snapshots": %{"jpg": "/Streaming/Channels/1/picture"}, "internal_rtsp_port": "", "internal_http_port": "", "internal_host": "", "external_rtsp_port": 9101, "external_http_port": 8101, "external_host": "5.149.169.19", "auth": %{"basic": %{"username": "admin","password": "mehcam"}}}}

    Repo.insert %Camera{name: "Y-cam DevCam", exid: "y_cam_devcam", owner_id: user.id, is_public: false, config: %{"snapshots": %{"jpg": "/snapshot.jpg"}, "internal_rtsp_port": "", "internal_http_port": "", "internal_host": "", "external_rtsp_port": "", "external_http_port": 8013, "external_host": "5.149.169.19", "auth": %{"basic": %{"username": "", "password": ""}}}}

    Repo.insert %Camera{name: "Evercam Devcam", exid: "evercam-remembrance-camera", owner_id: user.id, is_public: true, config: %{"snapshots": %{"jpg": "/Streaming/Channels/1/picture"}, "internal_rtsp_port": 0, "internal_http_port": 0, "internal_host": "", "external_rtsp_port": 90, "external_http_port": 80, "external_host": "149.5.38.22", "auth": %{"basic": %{"username": "guest", "password": "guest"}}}}
  end
end
