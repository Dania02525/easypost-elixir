defmodule Easypost.Address do
  alias Easypost.Helpers
  alias Easypost.Requester

  defstruct [
    id: "",
    object: "Address",
    street1: "",
    street2: "",
    city: "",
    state: "",
    zip: "",
    country: "",
    name: "",
    company: "",
    phone: "",
    email: "",
    residential: false,
    created_at: "",
    updated_at: ""
  ]

  @type t :: %__MODULE__{
    id: String.t,
    object: String.t,
    street1: String.t,
    street2: String.t,
    city: String.t,
    state: String.t,
    zip: String.t,
    country: String.t,
    name: String.t,
    company: String.t,
    phone: String.t,
    email: String.t,
    residential: boolean,
    created_at: String.t,
    updated_at: String.t
  }

  @spec create_address(map, map) :: Easypost.Address.t
  def create_address(conf, address) do  
    body = Helpers.encode(%{"address" => address})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/addresses"), conf[:key], [], ctype, body) do
      {:ok, address}->
        {:ok, struct(Easypost.Address, address)}
      {:error, _status, reason}->
        {:error, struct(Easypost.Error, reason)}
    end
  end

end