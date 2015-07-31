# Elixir Easypost Client


```elixir
# config/config.exs

config :my_app, easypost_endpoint: "https://api.easypost.com/v2/",
                easypost_key: "##############",
                easypost_test_key: "############"
```

### Use

```elixir
defmodule MyApp.Somemodule do
  use Easypost.Client, endpoint: Application.get_env(:my_app, :easypost_endpoint),                    
 					   key: Application.get_env(:my_app, :easypost_key)

  #add an address, where address is map like %{name: "something", street1: "something" ...etc} returned map has easypost address id
  def add_shipping_address(user) do
    case create_address(user.address) do
      {:ok, response} ->
        response
      {:error, status, reason} ->
        reason
    end
  end

  #get quotes for shipment when shipment is map like %{from_address: %{name: "something"}, to_address: %{name: "something"}, parcel: %{width: "something"}}
  def get_shipping_quotes(shipment) do
    case create_shipment(shipment) do
      {:ok, response} ->
        response
      {:error, status, reason} ->
        reason
    end
  end

  #returns postage label with print url when rate is like: %{id: "id of chosen rate"}
  def ship_package(shipment_id, rate) do
    case buy_shipment(shipment_id, rate) do
      {:ok, response} ->
        response
      {:error, status, reason} ->
        reason
    end
  end

  #create batch shipment when shipments is list like [%{from_address: %{name: "something"}, to_address: %{name: "something"}, parcel: %{width: "something"}}, %{id: "12346"}]
  def start_batch(shipments) do
    case create_batch(shipments) do
      {:ok, response} ->
        response
      {:error, status, reason} ->
        reason
    end
  end
end

```

Please visit easypost api documentation to see requred fields for each request at https://www.easypost.com/docs/api

### Installation

```elixir
def deps do
  [ {:easypost, git: "https://github.com/Dania02525/easypost-elixir.git"}]
end
```

### Notes

* Some tests are disabled and can only be used in production mode.  You may remove the the exlusion in the unit test and use your production API, but remember this will create shipments you probably don't want!

* The "insure shipment" test occasionally fails with the code SHIPMENT.POSTAGE.REQUIRED. I think this has to do with the timing of the requests in the test suite. 

