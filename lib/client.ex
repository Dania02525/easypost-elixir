defmodule Easypost.Client do

  defmacro __using__(config) do
    quote do
      def conf, do: unquote(config)
      def verify_address(address) do
        unquote(__MODULE__).verify_address(conf(), address)
      end
      def create_shipment(from, to, package) do
        unquote(__MODULE__).create_shipment(conf(), from, to, package)
      end
      def buy_shipment(shipment_id, rate_id) do
        unquote(__MODULE__).buy_shipment(conf(), shipment_id, rate_id)
      end
    end
  end

  def verify_address(conf, address) do
  	data = %{
  	  name: Dict.get(address, :name, ""),
  	  company: Dict.get(address, :company, ""),
  	  street1: Dict.fetch!(address, :street1),
  	  street2: Dict.get(address, :street2, ""),
  	  city: Dict.fetch!(address, :city),
  	  state: Dict.fetch!(address, :state),
  	  zip: Dict.fetch!(address, :zip),
  	  country: Dict.get(address, :country, "US"),
  	  email: Dict.get(address, :email, "")
  	}
  	ctype = 'application/x-www-form-urlencoded'
  	body  = URI.encode_query(data)

  	request(:post, url(conf[:endpoint], "/something"), conf[:key], ctype, body)
  end

  def create_shipment(conf, from, to, package) do

  end

  def buy_shipment(conf, shipment_id, rate_id) do

  end

  def url(domain, path), do: Path.join([domain, path])

  def request(method, url, key, headers, ctype, body) do
  	url = String.to_char_list(url)

	case method do
	  :get ->
	    headers = headers ++ [auth_header(key)]
	    :httpc.request(:get, {url, headers}, [], body_format: :binary)
	  _ ->
	    headers = headers ++ [auth_header(key), {'Content-Type', ctype}]
	    :httpc.request(method, {url, headers, ctype, body}, [], body_format: :binary)
	end 
	|> parse_response 	
  end

  defp auth_header(key) do
	{'Authorization', 'Basic ' ++ String.to_char_list(key <> ":")}
  end

  defp parse_response(response) do
  	case response do
  	  {:ok, {{_httpvs, 200, _status_phrase}, json_body}} ->
	    {:ok, json_body}
	  {:ok, {{_httpvs, 200, _status_phrase}, _headers, json_body}} ->
	    {:ok, json_body}
	  {:ok, {{_httpvs, status, _status_phrase}, json_body}} ->
		{:error, status, json_body}
	  {:ok, {{_httpvs, status, _status_phrase}, _headers, json_body}} ->
		{:error, status, json_body}
	  {:error, reason} -> {:error, :bad_fetch, reason}
  	end
  end
end

