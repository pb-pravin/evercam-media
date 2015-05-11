defmodule CameraShare do
  use Ecto.Model

  schema "camera_shares" do
    belongs_to :camera, Camera
    belongs_to :user, User
  end

  def for_camera(id) do
    from cam_share in CameraShare,
    where: cam_share.camera_id == ^id,
    select: cam_share,
    preload: :user
  end
end
