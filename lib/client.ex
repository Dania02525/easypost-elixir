defmodule Easypost.Client do

  defmacro __using__(config) do
    quote do
      def conf, do: unquote(config)
      def create_address(address) do
        unquote(__MODULE__).create_address(conf(), address)
      end
      def create_parcel(parcel) do
        unquote(__MODULE__).create_parcel(conf(), parcel)
      end
      def create_shipment(shipment) do
        unquote(__MODULE__).create_shipment(conf(), shipment)
      end
      def insure_shipment(shipment_id, insurance) do
        unquote(__MODULE__).insure_shipment(conf(), shipment_id, insurance)
      end
      def buy_shipment(shipment_id, rate) do
        unquote(__MODULE__).buy_shipment(conf(), shipment_id, rate)
      end
      def create_customs_forms(customs_info) do
        unquote(__MODULE__).create_customs_forms(conf(), customs_info)
      end
      def create_pickup(pickup) do
        unquote(__MODULE__).create_pickup(conf(), pickup)
      end
      def buy_pickup(pickup_id, pickup) do
        unquote(__MODULE__).buy_pickup(conf(), pickup_id, pickup)
      end
      def cancel_pickup(pickup_id) do
        unquote(__MODULE__).cancel_pickup(conf(), pickup_id)
      end
      def track(tracking) do
        unquote(__MODULE__).track(conf(), tracking)
      end
      def add_user(user) do
        unquote(__MODULE__).add_user(conf(), user)
      end
      def get_child_api_keys() do
        unquote(__MODULE__).get_child_api_keys(conf())
      end
      def add_carrier_account(carrier) do
        unquote(__MODULE__).add_carrier_account(conf(), carrier)
      end
      def refund_usps_label(shipment_id) do
        unquote(__MODULE__).refund_usps_label(conf(), shipment_id)
      end
    end
  end

  def create_address(conf, address) do 	
    body = encode(address)
  	ctype = 'application/x-www-form-urlencoded'

  	request(:post, url(conf[:endpoint], "/addresses"), conf[:key], [], ctype, body)
  end

  def create_shipment(conf, shipment) do
    body = encode(shipment)
    ctype = 'application/x-www-form-urlencoded'

    request(:post, url(conf[:endpoint], "/shipments"), conf[:key], [], ctype, body)
  end

  def buy_shipment(conf, shipment_id, rate) do
    body = encode(rate)
    ctype = 'application/x-www-form-urlencoded'

    request(:post, url(conf[:endpoint], "/shipments/" <> shipment_id <> "/buy"), conf[:key], [], ctype, body)
  end

  ##Utilities

  def encode(map) do
    map
      |> Enum.map(fn({k,v})-> process(Atom.to_string(k), v) end)
      |> List.flatten
      |> URI.encode_query
  end

  def process(acc, v) when is_map(v) do
    v 
    |> Enum.map(fn({k, v})-> process(acc <> "[" <> Atom.to_string(k) <> "]", v) end)
  end

  def process(acc, v) when is_list(v) do
    v 
    |> Enum.with_index
    |> Enum.map(fn({v, i})-> process(acc <> "[" <> Integer.to_string(i) <> "]", v) end)
  end

  def process(acc, v) do
    {acc, v}
  end

  def url(domain, path), do: Path.join([domain, path])

  def request(method, url, key, headers, ctype, body) do
  	url = String.to_char_list(url)
  	case method do
  	  :get ->
  	    headers = headers ++ [auth_header(key)]
  	    :httpc.request(:get, {url, headers}, [], [])
  	  _ ->
  	    headers = headers ++ [auth_header(key), {'Content-Type', ctype}]
  	    :httpc.request(method, {url, headers, ctype, body}, [], body_format: :binary)
  	end 
  	|> parse_response

  end

  defp auth_header(key) do
	{'Authorization', 'Basic ' ++ String.to_char_list(Base.encode64(key <> ":"))}
  end

  defp parse_response(response) do
  	case response do
  	  {:ok, {{_httpvs, 200, _status_phrase}, json_body}} ->
	      {:ok, Poison.decode!(json_body)}
      {:ok, {{_httpvs, 201, _status_phrase}, json_body}} ->
        {:ok, Poison.decode!(json_body)}
	    {:ok, {{_httpvs, 200, _status_phrase}, _headers, json_body}} ->
	      {:ok, Poison.decode!(json_body)}
      {:ok, {{_httpvs, 201, _status_phrase}, _headers, json_body}} ->
        {:ok, Poison.decode!(json_body)}
	    {:ok, {{_httpvs, status, _status_phrase}, json_body}} ->
		    {:error, status, Poison.decode!(json_body)}
	    {:ok, {{_httpvs, status, _status_phrase}, _headers, json_body}} ->
		    {:error, status, Poison.decode!(json_body)}
	    {:error, reason} -> 
        {:error, :bad_fetch, reason}
  	end
  end
end

