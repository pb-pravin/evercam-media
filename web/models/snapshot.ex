defmodule Snapshot do
  use Ecto.Model

  schema "snapshots" do
    belongs_to :camera, Camera

    field :data, :string
    field :notes, :string
    field :created_at, Ecto.DateTime, default: Ecto.DateTime.utc
  end

  def for_camera(camera_id) do
    from snap in Snapshot,
    where: snap.camera_id == ^camera_id,
    select: snap
  end
end
