defmodule User do
  use Ecto.Model

  schema "users" do
    has_one :country, Country, foreign_key: :country_id
    has_many :cameras, Camera, foreign_key: :owner_id
    has_many :camera_shares, CameraShare

    field :username, :string
    field :password, :string
    field :firstname, :string
    field :lastname, :string
    field :email, :string
    field :country_id, :integer
  end
end
