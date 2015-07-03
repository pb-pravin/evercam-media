defmodule Camera do
  use Ecto.Model

  schema "cameras" do
    belongs_to :owner, User, foreign_key: :owner_id
    belongs_to :vendor_model, VendorModel, foreign_key: :model_id
    has_many :camera_shares, CameraShare
    has_many :snapshots, Snapshot

    field :exid, :string
    field :name, :string
    field :thumbnail_url, :string
    field :is_online, :boolean
    field :is_public, :boolean
    field :config, EvercamMedia.Types.JSON
    field :last_polled_at, Ecto.DateTime, default: Ecto.DateTime.utc
    field :last_online_at, Ecto.DateTime, default: Ecto.DateTime.utc
    field :updated_at, Ecto.DateTime, default: Ecto.DateTime.utc
    field :created_at, Ecto.DateTime, default: Ecto.DateTime.utc
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

  def recording?(camera) do
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
    Enum.any?(recording_cameras, &(camera.exid == &1))
  end
end
