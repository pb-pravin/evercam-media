defmodule Vendor do
  use Ecto.Model

  schema "vendors" do
    has_many :vendor_models, VendorModel

    field :exid, :string
    field :name, :string
  end
end
