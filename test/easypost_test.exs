defmodule EasypostTest do
  use ExUnit.Case, async: false
  ExUnit.configure exclude: [production_only: true]

  @validaddress1 %{company: "EasyPost", street1: "118 2nd Street", street2: "4th Floor", city: "San Francisco", state: "CA", zip: "94105", phone: "555-858-5555"}
  @validaddress2 %{name: "Dr. Steve Brule", street1: "179 N Harbor Dr", city: "Redondo Beach", state: "CA", zip: "90277", phone: "555-858-5555"}
  @validparcel %{length: "20.2", width: "10.9", height: "5", weight: "65.9"}
  @validcustomsinfo %{customs_info: %{customs_certify: "true", customs_signer: "Steve Brule", contents_type: "merchandise", restriction_type: "none", customs_items: [%{description: "Sweet shirts", quantity: "2", value: "23", weight: "11", hs_tariff_number: "654321", origin_country: "US"}]}}
  @validcarrieraccount %{type: "UpsAccount", description: "NY Location UPS account", reference: "ups02", credentials: %{account_number: "A1A1A1", user_id: "USERID", password: "PASSWORD",access_licence_number: "ALN",}}
  @partialpickuprequest %{reference: "internal_id_1234", min_datetime: "2014-10-20 17:10:59", max_datetime: "2014-10-21 10:22:40", instructions: "Special pickup instructions"}
  @validpickupconfirmation %{carrier: "FEDEX", service: "Same Day"}
  @validtracking %{tracker: %{tracking_code: "EZ7000000007", carrier: "UPS",}}
  @validuser %{user: %{name: "Acme, inc"}}

  setup_all do
    Easypost.start
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    {:ok, shipment} = Easypost.Client.create_shipment(config, %{ shipment: %{from_address: @validaddress1, to_address: @validaddress2, parcel: @validparcel, customs_info: @validcustomsinfo}})
    {:ok, shipment: shipment}
  end

  test "adding some valid address" do
  	config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]

  	{:ok, response} = Easypost.Client.create_address(config, %{address: @validaddress1})

  	assert Dict.has_key?(response, "id")
  end

  test "adding a parcel" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]

    {:ok, response} = Easypost.Client.create_parcel(config, %{parcel: @validparcel})

    assert Dict.has_key?(response, "id")
  end

  test "add customs info forms" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]

    {:ok, response} = Easypost.Client.create_customs_forms(config, @validcustomsinfo)

    assert Dict.has_key?(response, "id")
  end

  test "shipping to valid address without address or parcel ids" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    shipment = %{
      shipment: %{
        from_address: @validaddress1,
        to_address: @validaddress2,
        parcel: @validparcel
      }
    }

    {:ok, response} = Easypost.Client.create_shipment(config, shipment)

    assert Dict.has_key?(response, "rates")
  end

  test "create return shipment" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    shipment = %{
      shipment: %{
        from_address: @validaddress1,
        to_address: @validaddress2,
        parcel: @validparcel,
        is_return: "true"
      }
    }

    {:ok, response} = Easypost.Client.create_shipment(config, shipment)

    assert Dict.has_key?(response, "id")
  end

  test "creating shipment with saved addresses, customs info, and parcel", %{shipment: shipment} do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    shipment = %{
      shipment: %{
        from_address: %{id: shipment["from_address"]["id"]},
        to_address: %{id: shipment["to_address"]["id"]},
        parcel: %{id: shipment["parcel"]["id"]},
        customs_info: %{id: shipment["customs_info"]["id"]},        
      }
    }

    {:ok, response} = Easypost.Client.create_shipment(config, shipment)

    assert Dict.has_key?(response, "id")
  end

  test "insure shipment", %{shipment: shipment} do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    insurance = %{
      amount: "888.50",
    }
    shipment_id = shipment["id"]

    {:ok, response} = Easypost.Client.insure_shipment(config, shipment_id, insurance)

    assert Dict.has_key?(response, "insurance")
  end

  test "buy shipment", %{shipment: shipment} do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]

    selected_rate = shipment["rates"] |> List.first

    rate = %{
      rate: %{id: selected_rate["id"]}
    }

    shipment_id = shipment["id"]

    {:ok, response} = Easypost.Client.buy_shipment(config, shipment_id, rate)

    assert Dict.has_key?(response, "postage_label")
    assert String.match?(response["postage_label"]["label_url"], ~r/http*/)
  end

  @tag :production_only
  test "quote a pickup", %{shipment: shipment} do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    pickup = %{
      pickup: %{ 
        reference: "internal_id_1234",
        min_datetime: "2014-10-20 17:10:59",
        max_datetime: "2014-10-21 10:22:40",
        shipment: %{id: shipment["id"]},
        address: @validaddress1,
        instructions: "Special pickup instructions",
        }
    }

    {:ok, response} = Easypost.Client.create_pickup(config, pickup)

    assert Dict.has_key?(response, "pickup_rates")
  end

  @tag :production_only
  test "buy a pickup", %{shipment: shipment} do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)] 
    pickup = %{
      pickup: %{
        reference: "internal_id_1234",
        min_datetime: "2014-10-20 17:10:59",
        max_datetime: "2014-10-21 10:22:40",
        shipment: %{id: shipment["id"]},
        address: @validaddress1,
        instructions: "Special pickup instructions",
        }
    }

    {:ok, newpickup} = Easypost.Client.create_pickup(config, pickup)
    thispickuprate = newpickup["pickup_rates"] |> List.first
    {:ok, response} = Easypost.Client.buy_pickup(config, thispickuprate["id"], @validpickupconfirmation)

    assert response["status"] =="scheduled"
  end

  @tag :production_only
  test "cancel a pickup", %{shipment: shipment} do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    pickup = %{
      pickup: %{
        reference: "internal_id_1234",
        min_datetime: "2014-10-20 17:10:59",
        max_datetime: "2014-10-21 10:22:40",
        shipment: %{id: shipment["id"]},
        address: @validaddress1,
        instructions: "Special pickup instructions",
        }
    }

    {:ok, newpickup} = Easypost.Client.create_pickup(config, pickup)
    thispickuprate = newpickup["pickup_rates"] |> List.first
    {:ok, _confirmed} = Easypost.Client.buy_pickup(config, thispickuprate["id"], @validpickupconfirmation)

    {:ok, response} = Easypost.Client.cancel_pickup(config, newpickup["id"])

    assert response["status"] =="cancelled"
  end

  test "track a package by tracking number" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]

    {:ok, response} = Easypost.Client.track(config, @validtracking)

    assert Dict.has_key?(response, "id")
  end

  @tag :production_only
  test "add a child user" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]
    user = %{
      user: %{
        name: "Acme inc",
      }
    }

    {:ok, response} = Easypost.Client.create_user(config, user)

    assert Dict.has_key?(response, "id")
  end

  @tag :production_only
  test "get user child API keys" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]

    {:ok, response} = Easypost.Client.get_child_api_keys(config)

    assert Dict.has_key?(response, "keys")
  end

  @tag :production_only
  test "add_carrier account" do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]

    {:ok, response} = Easypost.Client.add_carrier_account(config, %{carrier_account: @validcarrieraccount})

    assert Dict.has_key?(response, "id")
  end

  test "refund USPS label", %{shipment: shipment} do
    config = [endpoint: Application.get_env(:my_app, :easypost_endpoint), key: Application.get_env(:my_app, :easypost_test_key)]

    {:ok, response} = Easypost.Client.refund_usps_label(config, shipment["id"])

    assert response["object"] == "Refund"
  end

end