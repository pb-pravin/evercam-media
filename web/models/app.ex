defmodule App do
  use Ecto.Model

  schema "apps" do
    belongs_to :camera, Camera, foreign_key: :camera_id

    field :local_recording, :boolean, default: false
    field :cloud_recording, :boolean, default: false
    field :motion_detection, :boolean, default: false
    field :watermark, :boolean, default: false
  end
end
