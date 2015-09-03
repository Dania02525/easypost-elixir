defmodule Easypost.Error do

  defstruct [
    code: "",
    message: "",
    errors: []
  ]

  @type t :: %__MODULE__{
    code: String.t,
    message: String.t,
    errors: list
  }

end