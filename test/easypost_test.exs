defmodule EasypostTest do
  use ExUnit.Case, async: false
  use Easypost.Client, endpoint: Application.get_env(:myapp, :easypost_endpoint), key: Application.get_env(:myapp, :easypost_test_key)

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
    shipment = create_shipment(%{"from_address" => @validaddress1, "to_address" => @validaddress2, "parcel" => @validparcel, "customs_info" => @validcustomsinfo})

    {:ok, shipment: shipment}
  end

  test "adding some valid address" do
  	address = create_address(@validaddress1)

    assert address.__struct__ == Easypost.Address
  end

  test "adding some invalid address" do
    result = create_address(%{})
    IO.inspect result
    assert result.__struct__ == Easypost.Error
  end

  test "adding a parcel" do
    parcel = create_parcel(@validparcel)

    assert parcel.__struct__ == Easypost.Parcel
  end

  test "add customs info forms" do
    customs_info = create_customs_info(@validcustomsinfo)

    assert customs_info.__struct__ == Easypost.CustomsInfo
  end

  test "shipping to valid address without address or parcel ids" do
    shipment = %{
      "from_address" => @validaddress1,
      "to_address" => @validaddress2,
      "parcel" => @validparcel
    }

    result = create_shipment(shipment)

    assert result.__struct__ == Easypost.Shipment
  end

  test "create return shipment" do
    shipment = %{
      "from_address" => @validaddress1,
      "to_address" => @validaddress2,
      "parcel" => @validparcel,
      "is_return" => "true"
    }
    result = create_shipment(shipment)

    assert result.__struct__ == Easypost.Shipment
  end

  test "creating shipment with saved addresses, customs info, and parcel", %{shipment: shipment} do
    shipment = %{
      "from_address" => %{"id" => shipment.from_address.id},
      "to_address" => %{"id" => shipment.to_address.id},
      "parcel" => %{"id" => shipment.parcel.id},
      "customs_info" => %{"id" => shipment.customs_info.id},        
    }
    result = create_shipment(shipment)

    assert result.__struct__ == Easypost.Shipment
  end

  test "insure shipment", %{shipment: shipment} do
    insurance = %{
      "amount" => "888.50",
    }

    result = insure_shipment(shipment.id, insurance)

    assert result.__struct__ == Easypost.Shipment
  end

  test "buy shipment", %{shipment: shipment} do
    selected_rate = shipment.rates |> List.first
    
    rate = %{"id" => selected_rate.id}

    result = buy_shipment(shipment.id, rate)

    assert result.postage_label.__struct__ == Easypost.PostageLabel
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

    result = create_batch(shipments)

    assert result.__struct__ == Easypost.Batch
    assert result.num_shipments == 2
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


    result = create_and_buy_batch(shipments)

    assert result.__struct__ == Easypost.Batch
    assert result.num_shipments == 2
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

    batch = create_batch(shipments)
    assert batch.num_shipments == 2
    result = add_to_batch(batch.id, [%{"id" => shipment.id}])

    assert result.__struct__ == Easypost.Batch
    assert result.num_shipments == 3
  end

  test "remove from batch", %{shipment: shipment} do
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

    batch = create_batch(shipments)

    added = add_to_batch(batch.id, [%{"id" => shipment.id}])

    assert added.num_shipments == 3

    result = remove_from_batch(batch.id, [%{"id" => shipment.id}])

    assert result.__struct__ == Easypost.Batch

    assert result.num_shipments == 2
  end

  @tag :production_only
  test "quote a pickup", %{shipment: shipment} do
    pickup = %{ 
      "reference" => "internal_id_1234",
      "min_datetime" => "2014-10-20 17:10:59",
      "max_datetime" => "2014-10-21 10:22:40",
      "shipment" => %{"id" => shipment.id},
      "address" => @validaddress1,
      "instructions" => "Special pickup instructions",
    }

    result = create_pickup(pickup)

    assert result.__struct__ == Easypost.Pickup
  end

  @tag :production_only
  test "buy a pickup", %{shipment: shipment} do 
    pickup = %{
      "reference" => "internal_id_1234",
      "min_datetime" => "2014-10-20 17:10:59",
      "max_datetime" => "2014-10-21 10:22:40",
      "shipment" => %{id: shipment.id},
      "address" => @validaddress1,
      "instructions" => "Special pickup instructions",
    }

    newpickup = create_pickup(pickup)
    thispickuprate = newpickup.pickup_rates |> List.first
    result = buy_pickup(thispickuprate.id, @validpickupconfirmation)

    assert result.__struct__ == Easypost.Pickup
    assert result.status == "scheduled"
  end

  @tag :production_only
  test "cancel a pickup", %{shipment: shipment} do
    pickup = %{
      "reference" => "internal_id_1234",
      "min_datetime" => "2014-10-20 17:10:59",
      "max_datetime" => "2014-10-21 10:22:40",
      "shipment" => %{"id" => shipment.id},
      "address" => @validaddress1,
      "instructions" => "Special pickup instructions",
    }

    newpickup = create_pickup(pickup)

    thispickuprate = newpickup.pickup_rates |> List.first

    _confirmed = buy_pickup(thispickuprate.id, @validpickupconfirmation)

    result = cancel_pickup(newpickup.id)

    assert result.__struct__ == Easypost.Pickup
    assert result.status == "cancelled"
  end

  test "track a package by tracking number" do
    result = track(@validtracking)

    assert result.__struct__ == Easypost.Tracker
  end

  @tag :production_only
  test "add a child user" do
    user = %{
      "name" => "Acme inc",
    }

    result = create_user(user)

    assert result.__struct__ == Easypost.User
  end

  @tag :production_only
  test "get user child API keys" do
    result = get_child_api_keys()

    assert Dict.has_key?(result, "keys")
  end

  @tag :production_only
  test "add_carrier account" do
    result = add_carrier_account(@validcarrieraccount)

    assert result.__struct__ == Easypost.CarrierAccount
  end

  @tag :production_only
  test "refund USPS label", %{shipment: shipment} do
    result = refund_usps_label(shipment.id)

    assert result.__struct__ == Easypost.Refund
  end

end