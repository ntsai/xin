defmodule Xin.Product do
  use Xin.Web, :model
  schema "product" do 
    belongs_to :volume,  Xin.Product  #容量
    field :sku_des,   :string, label: "编码说明"                  #SKU编码说明
    field :status,    :boolean,  default: true #状态
    timestamps
  end

  @required_fields ~w(sku_des)

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:sku_des])
    |> validate_required(@required_fields)
  end
    
end