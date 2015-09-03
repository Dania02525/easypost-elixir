defmodule Easypost.PickupRate do 

  defstruct [
    created_at: "",
    currency: "",
    mode: "",
    rate: 0,
    service: "",
    updated_at: "",
    carrier: "",
    pickup_id: "",
    id: "",
    object: "PickupRate"
  ]

  @type t :: %__MODULE__{
    created_at: String.t,
    currency: String.t,
    mode: String.t,
    rate: number,
    service: String.t,
    updated_at: String.t,
    carrier: String.t,
    pickup_id: String.t,
    id: String.t,
    object: String.t
  }

end