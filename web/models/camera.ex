defmodule Camera do
  use Ecto.Model

  schema "cameras" do
    belongs_to :owner, User, foreign_key: :owner_id
    belongs_to :vendor_model, VendorModel, foreign_key: :model_id
    has_many :camera_shares, CameraShare
    has_many :snapshots, Snapshot
    has_many :cloud_recordings, CloudRecording
    has_many :apps, App

    field :exid, :string
    field :name, :string
    field :timezone, :string
    field :thumbnail_url, :string
    field :is_online, :boolean
    field :is_public, :boolean
    field :config, EvercamMedia.Types.JSON
    field :last_polled_at, Ecto.DateTime, default: Ecto.DateTime.utc
    field :last_online_at, Ecto.DateTime, default: Ecto.DateTime.utc
    field :updated_at, Ecto.DateTime, default: Ecto.DateTime.utc
    field :created_at, Ecto.DateTime, default: Ecto.DateTime.utc
  end

  def get_vendor_exid_by_camera_exid(camera_id) do
    EvercamMedia.Repo.one from c in Camera,
    join: vm in assoc(c, :vendor_model),
    join: v in assoc(vm, :vendor),
    where: c.exid == ^camera_id,
    select: v.exid
  end

  def by_exid(camera_id) do
    from cam in Camera,
    where: cam.exid == ^camera_id,
    select: cam
  end

  def by_exid_with_owner(camera_id) do
    from cam in Camera,
    where: cam.exid == ^camera_id,
    select: cam,
    preload: :owner
  end

  def limit(count) do
    from cam in Camera,
    limit: ^count
  end

  def external_url(camera, type \\ "http") do
    host = camera.config["external_host"] |> to_string
    port = camera.config["external_#{type}_port"] |> to_string
    camera_url(host, port, type)
  end

  defp camera_url("", port, type) do
    nil
  end

  defp camera_url(host, "", type) do
    "#{type}://#{host}"
  end

  defp camera_url(host, port, type) do
    "#{type}://#{host}:#{port}"
  end

  def auth(camera) do
    "#{camera.config["auth"]["basic"]["username"]}:#{camera.config["auth"]["basic"]["password"]}"
  end

  def res_url(camera, type \\ "jpg") do
    url = "#{camera.config["snapshots"][type]}"
    if String.starts_with?(url, "/") || String.length(url) == 0 do
      "#{url}"
    else
      "/#{url}"
    end
  end

  def recording?(camera_with_recordings) do
    recording_cameras = [
      "bankers",
      "beefcammobile",
      "bennett",
      "carrollszoocam",
      "centralbankbuild",
      "dancecam",
      "daqrihack1",
      "daqrihack2",
      "dcctestdumpinghk",
      "devilsbitcidercam",
      "evercam-remembrance-camera",
      "gemcon-cathalbrugha",
      "gpocam",
      "hikdemo",
      "hw-hack-auditorium",
      "kanoodle-monks-back-door",
      "kanoodle-monks-bar",
      "kanoodle-monks-kitch",
      "kanoodle-monks-seats",
      "kanoodle-monks-stair",
      "kanoodle-monks-till",
      "landing-zone-backdoor",
      "landing-zone-front",
      "mac1",
      "mac2",
      "pch-hackcam1",
      "pch-hackcam2",
      "smartcity1",
      "stephens-green",
      "treacyconsulting1",
      "treacyconsulting2",
      "treacyconsulting3",
      "wayra-agora",
      "wayra_office",
      "wayrahikvision",
      "zipyard-navan-foh",
      "zipyard-ranelagh-foh"
    ]

    cloud_recording = List.first(camera_with_recordings.cloud_recordings)
    if cloud_recording == nil do
      false
    else
      cloud_recording.frequency == 60
    end
  end

  def schedule(camera_with_recordings) do
    cloud_recording = List.first(camera_with_recordings.cloud_recordings)
    if cloud_recording == nil do
      %{
        "Monday" => ["00:00-24:00"],
        "Tuesday" => ["00:00-24:00"],
        "Wednesday" => ["00:00-24:00"],
        "Thursday" => ["00:00-24:00"],
        "Friday" => ["00:00-24:00"],
        "Saturday" => ["00:00-24:00"],
        "Sunday" => ["00:00-24:00"],
      }
    else
      cloud_recording.schedule
    end
  end
end
