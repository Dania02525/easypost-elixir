defmodule EasypostTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Httpc

  setup_all do
    Easypost.start
  end

  test "adding some valid address" do
  	config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
  	address = %{
  	  company: "EasyPost",
  	  street1: "118 2nd Street",
  	  street2: "4th Floor",
  	  city: "San Francisco",
  	  state: "CA",
  	  zip: "94105",
  	}

  	{:ok, response} = Easypost.Client.add_address(config, address)

  	assert Dict.has_key?(response, "id")
  end

  test "verifying some valid address" do
  	config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
  	address = %{
  	  company: "EasyPost",
  	  street1: "118 2nd Street",
  	  street2: "4th Floor",
  	  city: "San Francisco",
  	  state: "CA",
  	  zip: "94105",
  	}

  	{:ok, response} = Easypost.Client.verify_address(config, address)

  	assert Dict.has_key?(response, "address")

  end

  test "shipping to valid address" do
  	config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
  	from = %{
  	  company: "EasyPost",
  	  street1: "118 2nd Street",
  	  street2: "4th Floor",
  	  city: "San Francisco",
  	  state: "CA",
  	  zip: "94105",
  	}
  	to = %{
  	  name: "Dr. Steve Brule",
  	  street1: "179 N Harbor Dr",
  	  city: "Redondo Beach",
  	  state: "CA",
  	  zip: "90277",
  	}
  	parcel = %{
	  length: "20.2",
	  width: "10.9",
	  height: "5",
	  weight: "65.9",
  	}

  	{:ok, response} = Easypost.Client.create_shipment(config, from, to, parcel)

  	assert Dict.has_key?(response, "rates")

  end

  test "get shipping quote and buy shipment" do
  	config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
  	from = %{
  	  company: "EasyPost",
  	  street1: "118 2nd Street",
  	  street2: "4th Floor",
  	  city: "San Francisco",
  	  state: "CA",
  	  zip: "94105",
  	}
  	to = %{
  	  name: "Dr. Steve Brule",
  	  street1: "179 N Harbor Dr",
  	  city: "Redondo Beach",
  	  state: "CA",
  	  zip: "90277",
  	}
  	parcel = %{
	  length: "20.2",
	  width: "10.9",
	  height: "5",
	  weight: "65.9",
  	}

  	{:ok, shipment} = Easypost.Client.create_shipment(config, from, to, parcel)
  	selected_rate = shipment["rates"]
  		              |> List.first

    {:ok, response} = Easypost.Client.buy_shipment(config, shipment["id"], selected_rate["id"])

    assert Dict.has_key?(response, "postage_label")

  end

end