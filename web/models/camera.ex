defmodule Camera do
  use Ecto.Model

  schema "cameras" do
    belongs_to :owner, User, foreign_key: :owner_id
    belongs_to :vendor_model, VendorModel, foreign_key: :model_id
    has_many :camera_shares, CameraShare
    has_many :snapshots, Snapshot

    field :exid, :string
    field :is_online, :boolean
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
      "beefcam1",
      "beefcam2",
      "beefcammobile",
      "bennett",
      "carrollszoocam",
      "centralbankbuild",
      "dancecam",
      "dcctestdumpinghk",
      "devilsbitcidercam",
      "evercam-remembrance-camera",
      "gemcon-cathalbrugha",
      "gpocam",
      "hw-hack-auditorium",
      "landing-zone-backdoor",
      "landing-zone-front",
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
