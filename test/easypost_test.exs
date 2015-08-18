defmodule EasypostTest do
  use ExUnit.Case, async: false
  use Easypost.Client, endpoint: "https://api.easypost.com/v2/", key: "lRN9kaRaCaugYUugMFPiaQ"

  ExUnit.configure exclude: [production_only: true]

  @validaddress1 %{"company" => "EasyPost", "street1" => "118 2nd Street", "street2" => "4th Floor", "city" => "San Francisco", "state" => "CA", "zip" => "94105", "phone" => "555-858-5555"}
  @validaddress2 %{"name" => "Dr. Steve Brule", "street1" => "179 N Harbor Dr", "city" => "Redondo Beach", "state" => "CA", "zip" => "90277", "phone" => "555-858-5555"}
  @validparcel %{"length" => "20.2", "width" => "10.9", "height" => "5", "weight" => "65.9"}
  @validcustomsinfo %{"customs_certify" => "true", "customs_signer" => "Steve Brule", "contents_type" => "merchandise", "restriction_type" => "none", "customs_items" => [%{"description" => "Sweet shirts", "quantity" => "2", "value" => "23", "weight" => "11", "hs_tariff_number" => "654321", "origin_country" => "US"}]}
  @validcarrieraccount %{"type" => "UpsAccount", "description" => "NY Location UPS account", "reference" => "ups02", "credentials" => %{"account_number" => "A1A1A1", "user_id" => "USERID", "password" => "PASSWORD", "access_licence_number" => "ALN",}}
  @partialpickuprequest %{"reference" => "internal_id_1234", "min_datetime" => "2014-10-20 17:10:59", "max_datetime" => "2014-10-21 10:22:40", "instructions" => "Special pickup instructions"}
  @validpickupconfirmation %{"carrier" => "FEDEX", "service" => "Same Day"}
  @validtracking %{"tracking_code" => "EZ7000000007", "carrier" => "UPS",}
  @validuser %{"name" => "Acme, inc"}

  setup_all do
    Easypost.start
    {:ok, shipment} = create_shipment(%{"from_address" => @validaddress1, "to_address" => @validaddress2, "parcel" => @validparcel, "customs_info" => @validcustomsinfo})
    {:ok, shipment: shipment}
  end

  test "adding some valid address" do
  	{:ok, response} = create_address(@validaddress1)

  	assert Dict.has_key?(response, "id")
  end

  test "adding a parcel" do
    {:ok, response} = create_parcel(@validparcel)

    assert Dict.has_key?(response, "id")
  end

  test "add customs info forms" do
    {:ok, response} = create_customs_forms(@validcustomsinfo)

    assert Dict.has_key?(response, "id")
  end

  test "shipping to valid address without address or parcel ids" do
    shipment = %{
      "from_address" => @validaddress1,
      "to_address" => @validaddress2,
      "parcel" => @validparcel
    }

    {:ok, response} = create_shipment(shipment)

    assert Dict.has_key?(response, "rates")
  end

  test "create return shipment" do
    shipment = %{
      "from_address" => @validaddress1,
      "to_address" => @validaddress2,
      "parcel" => @validparcel,
      "is_return" => "true"
    }
    {:ok, response} = create_shipment(shipment)

    assert Dict.has_key?(response, "id")
  end

  test "creating shipment with saved addresses, customs info, and parcel", %{shipment: shipment} do
    shipment = %{
      "from_address" => %{"id" => shipment["from_address"]["id"]},
      "to_address" => %{"id" => shipment["to_address"]["id"]},
      "parcel" => %{"id" => shipment["parcel"]["id"]},
      "customs_info" => %{"id" => shipment["customs_info"]["id"]},        
    }
    {:ok, response} = create_shipment(shipment)

    assert Dict.has_key?(response, "id")
  end

  test "insure shipment", %{shipment: shipment} do
    insurance = %{
      "amount" => "888.50",
    }
    shipment_id = shipment["id"]

    {:ok, response} = insure_shipment(shipment_id, insurance)

    assert Dict.has_key?(response, "insurance")
  end

  test "buy shipment", %{shipment: shipment} do
    selected_rate = shipment["rates"] |> List.first

    rate = %{"id" => selected_rate["id"]}

    shipment_id = shipment["id"]

    {:ok, response} = buy_shipment(shipment_id, rate)

    assert Dict.has_key?(response, "postage_label")
    assert String.match?(response["postage_label"]["label_url"], ~r/http*/)
  end

  test "create batch shipment" do
    shipments = [
      %{
        "from_address" => @validaddress1,
        "to_address" => @validaddress2,
        "parcel" => @validparcel,       
      },
      %{
        "from_address" => @validaddress2,
        "to_address" => @validaddress1,
        "parcel" => @validparcel,       
      },
    ]

    {:ok, response} = create_batch(shipments)

    assert response["object"] == "Batch"
  end

  test "create and buy batch" do
     shipments = [
      %{
        "from_address" => @validaddress1,
        "to_address" => @validaddress2,
        "parcel" => @validparcel, 
        "carrier" => "USPS",
        "service" => "Priority",      
      },
      %{
        "from_address" => @validaddress2,
        "to_address" => @validaddress1,
        "parcel" => @validparcel,
        "carrier" => "USPS",
        "service" => "Priority",       
      },
    ]

    {:ok, response} = create_and_buy_batch(shipments)

    assert response["object"] == "Batch"
  end

  test "add to batch", %{shipment: shipment} do
     shipments = [
      %{
        "from_address" => @validaddress1,
        "to_address" => @validaddress2,
        "parcel" => @validparcel, 
        "carrier" => "USPS",
        "service" => "Priority",      
      },
      %{
        "from_address" => @validaddress2,
        "to_address" => @validaddress1,
        "parcel" => @validparcel,
        "carrier" => "USPS",
        "service" => "Priority",       
      },
    ]

    {:ok, batch} = create_batch(shipments)

    {:ok, response} = add_to_batch(batch["id"], [%{"id" => shipment["id"]}])

    assert response["object"] == "Batch"
    assert Enum.count(response["shipments"], fn(x)-> x["id"] == shipment["id"] end) == 1
  end

  test "remove from batch" do
     shipments = [
      %{
        "from_address" => @validaddress1,
        "to_address" => @validaddress2,
        "parcel" => @validparcel, 
        "carrier" => "USPS",
        "service" => "Priority",      
      },
      %{
        "from_address" => @validaddress2,
        "to_address" => @validaddress1,
        "parcel" => @validparcel,
        "carrier" => "USPS",
        "service" => "Priority",       
      },
    ]

    {:ok, batch} = create_batch(shipments)
    firstshipment = batch["shipments"] |> List.first

    {:ok, response} = remove_from_batch(batch["id"], [%{"id" => firstshipment["id"]}])

    assert response["object"] == "Batch"
    assert Enum.count(response["shipments"], fn(x)-> x["id"] == firstshipment["id"] end) == 0
  end

  @tag :production_only
  test "quote a pickup", %{shipment: shipment} do
    pickup = %{ 
      "reference" => "internal_id_1234",
      "min_datetime" => "2014-10-20 17:10:59",
      "max_datetime" => "2014-10-21 10:22:40",
      "shipment" => %{"id" => shipment["id"]},
      "address" => @validaddress1,
      "instructions" => "Special pickup instructions",
    }

    {:ok, response} = create_pickup(pickup)

    assert Dict.has_key?(response, "pickup_rates")
  end

  @tag :production_only
  test "buy a pickup", %{shipment: shipment} do 
    pickup = %{
      "reference" => "internal_id_1234",
      "min_datetime" => "2014-10-20 17:10:59",
      "max_datetime" => "2014-10-21 10:22:40",
      "shipment" => %{id: shipment["id"]},
      "address" => @validaddress1,
      "instructions" => "Special pickup instructions",
    }

    {:ok, newpickup} = create_pickup(pickup)
    thispickuprate = newpickup["pickup_rates"] |> List.first
    {:ok, response} = buy_pickup(thispickuprate["id"], @validpickupconfirmation)

    assert response["status"] =="scheduled"
  end

  @tag :production_only
  test "cancel a pickup", %{shipment: shipment} do
    pickup = %{
      "reference" => "internal_id_1234",
      "min_datetime" => "2014-10-20 17:10:59",
      "max_datetime" => "2014-10-21 10:22:40",
      "shipment" => %{"id" => shipment["id"]},
      "address" => @validaddress1,
      "instructions" => "Special pickup instructions",
    }

    {:ok, newpickup} = create_pickup(pickup)

    thispickuprate = newpickup["pickup_rates"] |> List.first

    {:ok, _confirmed} = buy_pickup(thispickuprate["id"], @validpickupconfirmation)

    {:ok, response} = cancel_pickup(newpickup["id"])

    assert response["status"] =="cancelled"
  end

  test "track a package by tracking number" do
    {:ok, response} = track(@validtracking)

    assert Dict.has_key?(response, "id")
  end

  @tag :production_only
  test "add a child user" do
    user = %{
      "name" => "Acme inc",
    }

    {:ok, response} = create_user(user)

    assert Dict.has_key?(response, "id")
  end

  @tag :production_only
  test "get user child API keys" do
    {:ok, response} = get_child_api_keys()

    assert Dict.has_key?(response, "keys")
  end

  @tag :production_only
  test "add_carrier account" do
    {:ok, response} = add_carrier_account(@validcarrieraccount)

    assert Dict.has_key?(response, "id")
  end

  @tag :production_only
  test "refund USPS label", %{shipment: shipment} do
    {:ok, response} = refund_usps_label(shipment["id"])

    assert response == "Refund"
  end

end