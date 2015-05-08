defmodule CameraActivity do
  use Ecto.Model

  schema "camera_activities" do
    belongs_to :camera, Camera

    field :action, :string
    field :done_at, Ecto.DateTime, default: Ecto.DateTime.utc
  end
end
