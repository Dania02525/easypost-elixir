defmodule Easypost.Shipment do
  alias Easypost.Helpers
  alias Easypost.Requester

  defstruct [
    id: "",
    object: "Shipment",
    mode: "",
    to_address: nil,
    from_address: nil,
    parcel: nil,
    customs_info: nil,
    rates: [],
    scan_form: "",
    selected_rate: nil,
    postage_label: nil,
    return_label: "",
    tracking_code: "",
    refund_status: "",
    insurance: 0,
    carrier_accounts: [],
    refund_status: "",
    batch_status: "",
    batch_message: "",
    is_return: false,
    additional_handling: false,
    address_validation_level: 1,
    alcohol: false,
    bill_receiver_account: "",
    bill_receiver_postal_code: "",
    bill_third_party_account: "",
    bill_third_party_postal_code: "",
    by_drone: false,
    carbon_neutral: false,
    cod_amount: 0,
    currency: "",
    date_advance: 0,
    delivery_duty_paid: true,
    delivery_confirmation: "NO_SIGNATURE",
    dry_ice: 0,
    dry_ice_medical: 0,
    dry_ice_weight: 0,
    handling_instructions: "",
    hold_for_pickup: false,
    invoice_number: "",
    label_format: "",
    machinable: 1,
    po_facility: "",
    po_zip: "",
    print_custom_1: "",
    print_custom_2: "",
    saturday_delivery: 0,
    special_rates_eligibility: "",
    smartpost_hub: "",
    smartpost_manifest: "",
    created_at: "",
    updated_at: ""
  ]

  @type t :: %__MODULE__{
    id: String.t,
    object: String.t,
    mode: String.t,
    to_address: Easypost.Address | nil,
    from_address: Easypost.Address | nil,
    parcel: Easypost.Parcel | nil,
    customs_info: Easypost.CustomsInfo | nil,
    rates: list(Easypost.Rate),
    scan_form: String.t,
    selected_rate: Easypost.Rate | nil,
    postage_label: Easypost.PostageLabel | nil,
    return_label: String.t,
    tracking_code: String.t,
    refund_status: String.t,
    insurance: number,
    carrier_accounts: list(Easypost.CarrierAccount),
    refund_status: String.t,
    batch_status: String.t,
    batch_message: String.t,
    is_return: boolean,
    additional_handling: boolean,
    address_validation_level: number,
    alcohol: boolean,
    bill_receiver_account: String.t,
    bill_receiver_postal_code: String.t,
    bill_third_party_account: String.t,
    bill_third_party_postal_code: String.t,
    by_drone: boolean,
    carbon_neutral: boolean,
    cod_amount: number,
    currency: String.t,
    date_advance: number,
    delivery_duty_paid: boolean,
    delivery_confirmation: String.t,
    dry_ice: number,
    dry_ice_medical: number,
    dry_ice_weight: number,
    handling_instructions: String.t,
    hold_for_pickup: boolean,
    invoice_number: String.t,
    label_format: String.t,
    machinable: number,
    po_facility: String.t,
    po_zip: String.t,
    print_custom_1: String.t,
    print_custom_2: String.t,
    saturday_delivery: number,
    special_rates_eligibility: String.t,
    smartpost_hub: String.t,
    smartpost_manifest: String.t,
    created_at: String.t,
    updated_at: String.t
  }

  @spec create_shipment(map, map) :: Easypost.Shipment.t
  def create_shipment(conf, shipment) do
    body = Helpers.encode(%{"shipment" => shipment})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/shipments"), conf[:key], [], ctype, body) do
      {:ok, shipment}->
        {:ok, struct(Easypost.Shipment, shipment)}
      {:error, _status, reason}->
        {:error, struct(Easypost.Error, reason)}
    end
  end

  @spec refund_usps_label(map, String.t) :: Easypost.Refund.t
  def refund_usps_label(conf, shipment_id) do
    body = []
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:get, Helpers.url(conf[:endpoint], "/shipments/" <> shipment_id <> "/refund"), conf[:key], [], ctype, body) do
      {:ok, refund}->
        {:ok, struct(Easypost.Refund, refund)}
      {:error, _status, reason}->
        {:error, struct(Easypost.Error, reason)}
    end
  end

  @spec insure_shipment(map, String.t, map) :: Easypost.Shipment.t
  def insure_shipment(conf, shipment_id, insurance) do
    body = Helpers.encode(insurance)
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/shipments/" <> shipment_id <> "/insure"), conf[:key], [], ctype, body) do
      {:ok, shipment}->
        {:ok, struct(Easypost.Shipment, shipment)}
      {:error, _status, reason}->
        {:error, struct(Easypost.Error, reason)}
    end
  end

  @spec buy_shipment(map, String.t, map) :: Easypost.Shipment.t
  def buy_shipment(conf, shipment_id, rate) do
    body = Helpers.encode(%{"rate" => rate})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/shipments/" <> shipment_id <> "/buy"), conf[:key], [], ctype, body) do
      {:ok, shipment}->
        {:ok, struct(Easypost.Shipment, shipment)}
      {:error, _status, reason}->
        {:error, struct(Easypost.Error, reason)}
    end
  end

end
