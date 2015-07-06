defmodule Easypost.Client do

  defmacro __using__(config) do
    quote do
      def conf, do: unquote(config)
      def add_address(address) do
        unquote(__MODULE__).add_address(conf(), address)
      end
      def verify_address(address) do
        unquote(__MODULE__).verify_address(conf(), address)
      end
      def create_shipment(from, to, parcel) do
        unquote(__MODULE__).create_shipment(conf(), from, to, parcel)
      end
      def buy_shipment(shipment_id, rate_id) do
        unquote(__MODULE__).buy_shipment(conf(), shipment_id, rate_id)
      end
    end
  end

  def add_address(conf, address) do
  	body = %{
  	  "name" => Dict.get(address, :name, ""),
  	  "company" => Dict.get(address, :company, ""),
  	  "street1" => Dict.fetch!(address, :street1),
  	  "street2" => Dict.get(address, :street2, ""),
  	  "city" => Dict.fetch!(address, :city),
  	  "state" => Dict.fetch!(address, :state),
  	  "zip" => Dict.fetch!(address, :zip),
  	  "country" => Dict.get(address, :country, "US"),
  	  "email" => Dict.get(address, :email, "")
  	}
      |> Enum.map(fn({k, v}) -> {"address[" <> k <> "]", v} end)
      |> URI.encode_query

  	ctype = 'application/x-www-form-urlencoded'

  	request(:post, url(conf[:endpoint], "/addresses"), conf[:key], [], ctype, body)
  end

  def verify_address(conf, address) do
    body = %{
      "name" => Dict.get(address, :name, ""),
      "company" => Dict.get(address, :company, ""),
      "street1" => Dict.fetch!(address, :street1),
      "street2" => Dict.get(address, :street2, ""),
      "city" => Dict.fetch!(address, :city),
      "state" => Dict.fetch!(address, :state),
      "zip" => Dict.fetch!(address, :zip),
      "country" => Dict.get(address, :country, "US"),
      "email" => Dict.get(address, :email, "")
    }
      |> Enum.map(fn({k, v}) -> {"address[" <> k <> "]", v} end)
      |> URI.encode_query

    ctype = 'application/x-www-form-urlencoded'

    request(:get, url(conf[:endpoint], "/addresses/create_and_verify?" <> body ), conf[:key], [], ctype, body)
  end

  def create_shipment(conf, from, to, parcel) do
    to_address = %{
      "name" => Dict.get(to, :name, ""),
      "company" => Dict.get(to, :company, ""),
      "street1" => Dict.fetch!(to, :street1),
      "street2" => Dict.get(to, :street2, ""),
      "city" => Dict.fetch!(to, :city),
      "state" => Dict.fetch!(to, :state),
      "zip" => Dict.fetch!(to, :zip),
      "country" => Dict.get(to, :country, "US"),
      "email" => Dict.get(to, :email, "")
    }
      |> Enum.map(fn({k, v}) -> {"shipment[to_address[" <> k <> "]]", v} end)

    from_address = %{
      "name" => Dict.get(from, :name, ""),
      "company" => Dict.get(from, :company, ""),
      "street1" => Dict.fetch!(from, :street1),
      "street2" => Dict.get(from, :street2, ""),
      "city" => Dict.fetch!(from, :city),
      "state" => Dict.fetch!(from, :state),
      "zip" => Dict.fetch!(from, :zip),
      "country" => Dict.get(from, :country, "US"),
      "email" => Dict.get(from, :email, "")
    }
      |> Enum.map(fn({k, v}) -> {"shipment[from_address[" <> k <> "]]", v} end)

    parcel = %{
      "length" => Dict.fetch!(parcel, :length),
      "width" => Dict.fetch!(parcel, :width),
      "height" => Dict.fetch!(parcel, :height),
      "weight" => Dict.fetch!(parcel, :weight)
    }
      |> Enum.map(fn({k, v}) -> {"shipment[parcel[" <> k <> "]]", v} end)

    body = List.flatten([to_address, from_address, parcel])
                 |> URI.encode_query

    ctype = 'application/x-www-form-urlencoded'

    request(:post, url(conf[:endpoint], "/shipments"), conf[:key], [], ctype, body)
  end

  def buy_shipment(conf, shipment_id, rate_id) do
    body = URI.encode_query([{"rate[id]", rate_id}])
    ctype = 'application/x-www-form-urlencoded'

    request(:post, url(conf[:endpoint], "/shipments/" <> shipment_id <> "/buy"), conf[:key], [], ctype, body)
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

