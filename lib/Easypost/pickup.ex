defmodule Easypost.Pickup do 
  alias Easypost.Helpers
  alias Easypost.Requester

  defstruct [
    id: "",
    object: "Pickup",
    created_at: "",
    updated_at: "",
    mode: "",
    status: "",
    reference: "",
    min_datetime: "",
    max_datetime: "",
    is_account_address: false,
    instructions: "",
    messages: [],
    confirmation: "",
    address: nil,
    carrier_accounts: [],
    pickup_rates: []
  ]

  @type t :: %__MODULE__{
    id: String.t,
    object: String.t,
    created_at: String.t,
    updated_at: String.t,
    mode: String.t,
    status: String.t,
    reference: String.t,
    min_datetime: String.t,
    max_datetime: String.t,
    is_account_address: boolean,
    instructions: String.t,
    messages: list,
    confirmation: String.t,
    address: Easypost.Address | nil,
    carrier_accounts: list(Easypost.CarrierAccount),
    pickup_rates: list(Easypost.PickupRate)
  }

  @spec create_pickup(map, map) :: Easypost.Pickup.t
  def create_pickup(conf, pickup) do
    body = Helpers.encode(%{"pickup" => pickup})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/pickups"), conf[:key], [], ctype, body) do
      {:ok, pickup}->
        struct(Easypost.Pickup, pickup)
      {:error, _status, reason}->
        struct(Easypost.Error, reason)
    end
  end

  @spec buy_pickup(map, String.t, map) :: Easypost.Pickup.t
  def buy_pickup(conf, pickup_id, pickup) do
    body = Helpers.encode(%{"pickup" => pickup})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/pickups/" <> pickup_id <> "/buy"), conf[:key], [], ctype, body) do
      {:ok, pickup}->
        struct(Easypost.Pickup, pickup)
      {:error, _status, reason}->
        struct(Easypost.Error, reason)
    end
  end

  @spec cancel_pickup(map, String.t) :: Easypost.Pickup.t
  def cancel_pickup(conf, pickup_id) do
    body = []
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/pickups/" <> pickup_id <> "/cancel"), conf[:key], [], ctype, body) do
      {:ok, pickup}->
        struct(Easypost.Pickup, pickup)
      {:error, _status, reason}->
        struct(Easypost.Error, reason)
    end
  end

end