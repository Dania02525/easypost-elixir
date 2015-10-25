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
    {_, shipment} = create_shipment(%{"from_address" => @validaddress1, "to_address" => @validaddress2, "parcel" => @validparcel, "customs_info" => @validcustomsinfo})

    {:ok, shipment: shipment}
  end

  test "adding some valid address" do
  	{_, address} = create_address(@validaddress1)

    assert address.__struct__ == Easypost.Address
  end

  test "adding some invalid address" do
    {_, result} = create_address(%{})
    assert result.__struct__ == Easypost.Error
  end

  test "adding a parcel" do
    {_, parcel} = create_parcel(@validparcel)

    assert parcel.__struct__ == Easypost.Parcel
  end

  test "add customs info forms" do
    {_, customs_info} = create_customs_info(@validcustomsinfo)

    assert customs_info.__struct__ == Easypost.CustomsInfo
  end

  test "shipping to valid address without address or parcel ids" do
    shipment = %{
      "from_address" => @validaddress1,
      "to_address" => @validaddress2,
      "parcel" => @validparcel
    }

    {_, result} = create_shipment(shipment)

    assert result.__struct__ == Easypost.Shipment
  end

  test "create return shipment" do
    shipment = %{
      "from_address" => @validaddress1,
      "to_address" => @validaddress2,
      "parcel" => @validparcel,
      "is_return" => "true"
    }
    {_, result} = create_shipment(shipment)

    assert result.__struct__ == Easypost.Shipment
  end

  test "creating shipment with saved addresses, customs info, and parcel", %{shipment: shipment} do
    shipment = %{
      "from_address" => %{"id" => shipment.from_address.id},
      "to_address" => %{"id" => shipment.to_address.id},
      "parcel" => %{"id" => shipment.parcel.id},
      "customs_info" => %{"id" => shipment.customs_info.id},        
    }
    {_, result} = create_shipment(shipment)

    assert result.__struct__ == Easypost.Shipment
  end

  test "insure shipment", %{shipment: shipment} do
    insurance = %{
      "amount" => "888.50",
    }

    {_, result} = insure_shipment(shipment.id, insurance)

    assert result.__struct__ == Easypost.Shipment
  end

  test "buy shipment", %{shipment: shipment} do
    selected_rate = shipment.rates |> List.first
    
    rate = %{"id" => selected_rate.id}

    {_, result} = buy_shipment(shipment.id, rate)

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

    {_, result} = create_batch(shipments)

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


    {_, result} = create_and_buy_batch(shipments)

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

    {_, batch} = create_batch(shipments)
    assert batch.num_shipments == 2
    {_,  result} = add_to_batch(batch.id, [%{"id" => shipment.id}])

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

    {_, batch} = create_batch(shipments)

    {_, added} = add_to_batch(batch.id, [%{"id" => shipment.id}])

    assert added.num_shipments == 3

    {_, result} = remove_from_batch(batch.id, [%{"id" => shipment.id}])

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

    {_, result} = create_pickup(pickup)

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

    {_, newpickup} = create_pickup(pickup)
    thispickuprate = newpickup.pickup_rates |> List.first
    {_, result} = buy_pickup(thispickuprate.id, @validpickupconfirmation)

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

    {_, newpickup} = create_pickup(pickup)

    thispickuprate = newpickup.pickup_rates |> List.first

    _confirmed = buy_pickup(thispickuprate.id, @validpickupconfirmation)

    {_,  result} = cancel_pickup(newpickup.id)

    assert result.__struct__ == Easypost.Pickup
    assert result.status == "cancelled"
  end

  test "track a package by tracking number" do
    {_, result} = track(@validtracking)

    assert result.__struct__ == Easypost.Tracker
  end

  @tag :production_only
  test "add a child user" do
    user = %{
      "name" => "Acme inc",
    }

    {_, result} = create_user(user)

    assert result.__struct__ == Easypost.User
  end

  @tag :production_only
  test "get user child API keys" do
    {_, result} = get_child_api_keys()

    assert Dict.has_key?(result, "keys")
  end

  @tag :production_only
  test "add_carrier account" do
    {_, result} = add_carrier_account(@validcarrieraccount)

    assert result.__struct__ == Easypost.CarrierAccount
  end

  @tag :production_only
  test "refund USPS label", %{shipment: shipment} do
    {_, result} = refund_usps_label(shipment.id)

    assert result.__struct__ == Easypost.Refund
  end

end