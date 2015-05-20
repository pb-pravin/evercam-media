defmodule VendorModel do
  use Ecto.Model

  schema "vendor_models" do
    belongs_to :vendor, Vendor
    has_many :cameras, Camera

    field :exid, :string
    field :name, :string
    field :config, EvercamMedia.Types.JSON
  end
end
