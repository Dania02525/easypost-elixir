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

  	{:ok, response} = Easypost.Client.create_address(config, address)

  	assert Dict.has_key?(response, "id")
  end

  test "adding a parcel" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    parcel = %{
      length: "20.2",
      width: "10.9",
      height: "5",
      weight: "65.9",
    }

    {:ok, response} = Easypost.Client.create_parcel(config, parcel)

    assert Dict.has_key?(response, "id")
  end

  test "insure shipment" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    insurance = %{
      amount: "888.50",
    }
    shipment_id = "shp_vN9h7XLn",

    {:ok, response} = Easypost.Client.insure_shipment(config, shipment_id, insurance)

    assert Dict.has_key?(response, "insurance")
  end

  test "create customs info forms" do
    customs_info = %{
      customs_certify: "true",
      customs_signer: "Steve Brule",
      contents_type: "merchandise",
      restriction_type: "none",
      customs_items: [
        %{description: "Sweet shirts", quantity: "2", value: "23", weight: "11", hs_tariff_number: "654321", origin_country: "US"}
      ]
    }

    {:ok, response} = Easypost.Client.create_customs_form(config, customs_info)

    assert Dict.has_key?(response, "id")
  end

  test "creating shipment with saved addresses, customs info, and parcel" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    shipment = %{
      from_address: %{id: "adr_HrBKVA85"},
      to_address: %{id: "adr_VtuTOj7o"},
      parcel: %{id: "prcl_WDv2VzHp"},
      customs_info: %{id: "cstinfo_bl5sE20Y"},
      is_return: "true"
    }

    {:ok, response} = Easypost.Client.create_shipment(config, shipment)

    assert Dict.has_key?(response, "id")
  end

  test "create return shipment" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    shipment = %{
      from_address: %{id: "adr_HrBKVA85"},
      to_address: %{id: "adr_VtuTOj7o"},
      parcel: %{id: "prcl_WDv2VzHp"},
      customs_info: %{id: "cstinfo_bl5sE20Y"},
    }

    {:ok, response} = Easypost.Client.create_shipmment(config, shipment)

    assert Dict.has_key?(response, "id")
  end

  test "shipping to valid address without address or parcel ids" do
  	config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    shipment = %{
      shipment: %{
      	from_address: %{
      	  company: "EasyPost",
      	  street1: "118 2nd Street",
      	  street2: "4th Floor",
      	  city: "San Francisco",
      	  state: "CA",
      	  zip: "94105",
      	},
      	to_address: %{
      	  name: "Dr. Steve Brule",
      	  street1: "179 N Harbor Dr",
      	  city: "Redondo Beach",
      	  state: "CA",
      	  zip: "90277",
      	}
      	parcel: %{
      	  length: "20.2",
      	  width: "10.9",
      	  height: "5",
      	  weight: "65.9",
      	}
      }
    }

  	{:ok, response} = Easypost.Client.create_shipment(config, shipment)

  	assert Dict.has_key?(response, "rates")
  end

  test "quote a pickup" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    pickup = %{
      reference: "internal_id_1234",
      min_datetime: "2014-10-20 17:10:59",
      max_datetime: "2014-10-21 10:22:40",
      shipment: %{id:"ALREADY_CREATED_SHIPMENT_ID"},
      address: %{
        name: "Sawyer Bateman", 
        street1: "118 2nd St", 
        city: "San Francisco", 
        state: "CA", 
        zip: "94105", 
        phone: "415-456-7890", 
        is_account_address: "true",
      }
      instructions: "Special pickup instructions",
    }

    {:ok, response} = Easypost.Client.create_pickup(config, pickup)

    assert Dict.has_key?(response, "pickup_rates")
  end

  test "buy and schedule a pickup" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    pickup = %{
      carrier: "FEDEX",
      service: "Same Day",
    }

    pickup_id = "pickup_ebae2c59mdk83jsh39ma3a056ab3d1f1"

    {:ok, response} = Easypost.Client.buy_pickup(config, pickup_id, pickup)

    assert Dict.has_key?(response, "id")
  end

  test "cancel a pickup" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    pickup_id = "pickup_ebae2c59mdk83jsh39ma3a056ab3d1f1"

    {:ok, response} = Easypost.Client.cancel_pickup(config, pickup_id)

    assert Dict.has_key?(response, "id")
  end

  test "track a package by tracking number" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    tracking = %{
      tracking_code: "1Z204E38YW95204424",
      carrier: "UPS",
    }

    {:ok, response} = Easypost.Client.track_shipment(config, tracking)

    assert Dict.has_key?(response, "id")
  end

  test "add a child user" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    user = %{
      name: "Acme inc",
    }

    {:ok, response} = Easypost.Client.add_user(config, user)

    assert Dict.has_key?(response, "id")
  end

  test "get user child API keys" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]

    {:ok, response} = Easypost.Client.get_child_api_keys(config)

    assert Dict.has_key?(response, "keys")
  end

  test "add_carrier account" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    carrier_account = %{
      type: "UpsAccount",
      description: "NY Location UPS account",
      reference: "ups02",
      credentials: %{
          account_number: "A1A1A1",
          user_id: "USERID",
          password: "PASSWORD",
          access_licence_number: "ALN",
      }
    }

    {:ok, response} = Easypost.Client.add_carrier_account(config, carrier_account)

    assert Dict.has_key?(response, "id")
  end

  test "refund USPS label" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    shipment_id = "shp_N3P0Ag8r"

    {:ok, response} = Easypost.Client.refund_usps_label(config, shipment_id)

    assert Dict.has_key?(response, "id")
  end

  test "get shipping quote and buy shipment" do
  	config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
  	shipment = %{
      from_address: %{
        company: "EasyPost",
        street1: "118 2nd Street",
        street2: "4th Floor",
        city: "San Francisco",
        state: "CA",
        zip: "94105",
      },
      to_address: %{
        name: "Dr. Steve Brule",
        street1: "179 N Harbor Dr",
        city: "Redondo Beach",
        state: "CA",
        zip: "90277",
      }
      parcel: %{
        length: "20.2",
        width: "10.9",
        height: "5",
        weight: "65.9",
      }
    }
  	{:ok, shipment} = Easypost.Client.create_shipment(config, shipment)
  	selected_rate = shipment["rates"]
  		              |> List.first

    {:ok, response} = Easypost.Client.buy_shipment(config, shipment["id"], selected_rate["id"])

    assert Dict.has_key?(response, "postage_label")

  end

end