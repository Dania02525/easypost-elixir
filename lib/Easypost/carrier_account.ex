defmodule Easypost.CarrierAccount do 

  defstruct [
    id: "",
    object: "CarrierAccount",
    type: "",
    description: "",
    reference: "",
    credentials: %{},
    test_credentials: %{},
    readable: "",
    logo: "",
    fields: %{},
    created_at: "",
    updated_at: ""
  ]

  @type t :: %__MODULE__{
    id: String.t,
    object: String.t,
    type: String.t,
    description: String.t,
    reference: String.t,
    credentials: map,
    test_credentials: map,
    readable: String.t,
    logo: String.t,
    fields: map,
    created_at: String.t,
    updated_at: String.t
  }

end