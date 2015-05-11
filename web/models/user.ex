defmodule User do
  use Ecto.Model

  schema "users" do
    has_many :cameras, Camera, foreign_key: :owner_id

    field :username, :string
  end
end
