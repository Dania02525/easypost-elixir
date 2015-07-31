defmodule Easypost.Client.Pickup do 
  alias Easypost.Client.Helpers
  alias Easypost.Client.Requester

   def create_pickup(conf, pickup) do
    body = Helpers.encode(%{pickup: pickup})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/pickups"), conf[:key], [], ctype, body)
  end

  def buy_pickup(conf, pickup_id, pickup) do
    body = Helpers.encode(%{pickup: pickup})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/pickups/" <> pickup_id <> "/buy"), conf[:key], [], ctype, body)
  end

  def cancel_pickup(conf, pickup_id) do
    body = []
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/pickups/" <> pickup_id <> "/cancel"), conf[:key], [], ctype, body)
  end

end