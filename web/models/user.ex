defmodule User do
  use Ecto.Model

  schema "users" do
    has_many :cameras, Camera, foreign_key: :owner_id
    has_many :camera_shares, CameraShare

    field :username, :string
  end
end
