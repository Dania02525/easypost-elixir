defmodule Easypost.User do 
  alias Easypost.Helpers
  alias Easypost.Requester

  defstruct [
    id: "",
    object: "User",
    name: "",
    email: "",
    phone_number: "",
    balance: "",
    recharge_amount: 0,
    secondary_recharge_amount: 0,
    recharge_threshold: 0,
    children: []
  ]

  @type t :: %__MODULE__{
    id: String.t,
    object: String.t,
    name: String.t,
    email: String.t,
    phone_number: String.t,
    balance: String.t,
    recharge_amount: number,
    secondary_recharge_amount: number,
    recharge_threshold: number,
    children: list
  }

  @spec get_child_api_keys(map) :: map
  def get_child_api_keys(conf) do
    body = []
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:get, Helpers.url(conf[:endpoint], "/api_keys"), conf[:key], [], ctype, body) do
      {:ok, result}->
        {:ok, result}
      {:error, _status, reason}->
        {:error, struct(Easypost.Error, reason)}
    end
  end

  @spec add_carrier_account(map, map) :: Easypost.CarrierAccount.t
  def add_carrier_account(conf, carrier) do
    body = Helpers.encode(%{"carrier_account" => carrier})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/carrier_accounts"), conf[:key], [], ctype, body) do
      {:ok, account}->
        {:ok, struct(Easypost.CarrierAccount, account)}
      {:error, _status, reason}->
        {:error, struct(Easypost.Error, reason)}
    end
  end

  @spec create_user(map, map) :: Easypost.User.t
  def create_user(conf, user) do
    body = Helpers.encode(%{"user" => user})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/users"), conf[:key], [], ctype, body) do
      {:ok, user}->
        {:ok, struct(Easypost.User, user)}
      {:error, _status, reason}->
        {:error, struct(Easypost.Error, reason)}
    end
  end

end