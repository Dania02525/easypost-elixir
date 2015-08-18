defmodule Easypost.Client.Shipment do 
  alias Easypost.Client.Helpers
  alias Easypost.Client.Requester

  def create_shipment(conf, shipment) do
    body = Helpers.encode(%{"shipment" => shipment})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/shipments"), conf[:key], [], ctype, body)
  end

  def refund_usps_label(conf, shipment_id) do
    body = []
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:get, Helpers.url(conf[:endpoint], "/shipments/" <> shipment_id <> "/refund"), conf[:key], [], ctype, body)
  end

  def insure_shipment(conf, shipment_id, insurance) do
    body = Helpers.encode(insurance)
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/shipments/" <> shipment_id <> "/insure"), conf[:key], [], ctype, body)
  end

  def buy_shipment(conf, shipment_id, rate) do
    body = Helpers.encode(%{"rate" => rate})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/shipments/" <> shipment_id <> "/buy"), conf[:key], [], ctype, body)
  end

end