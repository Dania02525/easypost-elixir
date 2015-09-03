defmodule Easypost.Rate do

  defstruct [
    id: "",
    object: "Rate",
    carrier_account_id: "",
    service: "",
    rate: 0,
    carrier: "",
    shipment_id: "",
    delivery_days: 0,
    delivery_date: "",
    delivery_date_guaranteed: false,
    created_at: "",
    updated_at: ""
  ]

  @type t :: %__MODULE__{
    id: String.t,
    object: String.t,
    carrier_account_id: String.t,
    service: String.t,
    rate: number,
    carrier: String.t,
    shipment_id: String.t,
    delivery_days: number,
    delivery_date: String.t,
    delivery_date_guaranteed: boolean,
    created_at: String.t,
    updated_at: String.t
  }

end