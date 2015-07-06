# Elixir Easypost Client


```elixir
# config/config.exs

config :my_app, easypost_endpoint: "https://api.easypost.com/v2/",
                easypost_key: "##############",
                easypost_test_key: "############"
```

### use

```elixir
defmodule MyApp.Somemodule do
  use Easypost.Client, endpoint: Application.get_env(:my_app, :easypost_endpoint),                    
 					   key: Application.get_env(:my_app, :easypost_key)

  #adds the address, verifies it, and returns address object NOTE: not currently working
  def verify_user_address(user) do
    case verify_address(user.address) do
      {:ok, response} ->
        response
      {:error, status, reason} ->
        reason
    end
  end

  #add an address, returns address object
  def add_shipping_address(user) do
    case add_address(user.address) do
      {:ok, response} ->
        response
      {:error, status, reason} ->
        reason
    end
  end

  #add an address and create a shipment all at once, returns shipment object + rate objects
  def get_shipping_quotes(from, to, parcel) do
    case create_shipment(from, to, parcel) do
      {:ok, response} ->
        response
      {:error, status, reason} ->
        reason
    end
  end

  #returns postage label object with print url
  def ship_package(shipment_id, rate_id) do
    case buy_shipment(shipment_id, rate_id) do
      {:ok, response} ->
        response
      {:error, status, reason} ->
        reason
    end
  end
end

```

### Installation

Note: This library is missing some features and probably needs work before using

```elixir
def deps do
  [ {:easypost, git: "https://github.com/Dania02525/easypost.git"}]
end
```