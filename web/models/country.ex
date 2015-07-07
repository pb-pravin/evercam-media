defmodule Country do
  use Ecto.Model

  schema "countries" do
    field :iso3166_a2, :string
    field :name, :string
  end
end
