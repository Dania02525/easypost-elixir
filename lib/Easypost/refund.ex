defmodule Easypost.Refund do 

  defstruct [
    id: "",
    object: "Refund",
    tracking_code: "",
    confirmation_number: "",
    status: "",
    carrier: "",
    shipment_id: "",
    created_at: "",
    updated_at: ""
  ]

  @type t :: %__MODULE__{
    id: String.t,
    object: String.t,
    tracking_code: String.t,
    confirmation_number: String.t,
    status: String.t,
    carrier: String.t,
    shipment_id: String.t,
    created_at: String.t,
    updated_at: String.t
  }

end