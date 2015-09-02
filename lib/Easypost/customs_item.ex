defmodule Easypost.CustomsItem do 
  alias Easypost.Helpers
  alias Easypost.Requester

  defstruct {
    id: "",
    object: "CustomsItem",
    description: "",
    quantity: 0,
    value: 0,
    weight: 0,
    hs_tariff_number: "",
    origin_country: "",
    created_at: "",
    updated_at: ""
  }

  @type t :: %__MODULE__{
    id: String.t,
    object: String.t,
    description: String.t,
    quantity: number,
    value: number,
    weight: number,
    hs_tariff_number: String.t,
    origin_country: String.t,
    created_at: String.t,
    updated_at: String.t
  }

  @spec create_customs_item(map, map) :: Easypost.CustomsItem.t
  def create_customs_item(conf, customs_item) do
    body = Helpers.encode(%{"customs_item" => customs_item})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/customs_items"), conf[:key], [], ctype, body) do
      {:ok, item}->
        struct(Easypost.CustomsItem, item)
      {:error, status, reason}->
        "Error: " <> status <> reason
    end
  end

end