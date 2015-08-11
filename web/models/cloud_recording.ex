defmodule CloudRecording do
  use Ecto.Model

  schema "cloud_recordings" do
    belongs_to :camera, Camera, foreign_key: :camera_id

    field :frequency, :integer
    field :storage_duration, :integer
    field :schedule, EvercamMedia.Types.JSON
  end
end
