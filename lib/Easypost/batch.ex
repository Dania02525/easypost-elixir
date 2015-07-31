defmodule Easypost.Client.Batch do 
  alias Easypost.Client.Helpers
  alias Easypost.Client.Requester

  def create_batch(conf, shipments) do
    body = Helpers.encode(%{batch: shipments})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/batches"), conf[:key], [], ctype, body)
  end

  def create_and_buy_batch(conf, shipments) do
    body = Helpers.encode(%{batch: shipments})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/batches/create_and_buy"), conf[:key], [], ctype, body)
  end

  def batch_labels(conf, batch_id, label) do
    body = Helpers.encode(label)
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/batches/" <> batch_id <> "/label"), conf[:key], [], ctype, body)
  end

  def add_to_batch(conf, batch_id, shipments) do
    body = Helpers.encode(%{shipments: shipments})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/batches/" <> batch_id <> "/add_shipments"), conf[:key], [], ctype, body)
  end

  def remove_from_batch(conf, batch_id, shipments) do
    body = Helpers.encode(%{shipments: shipments})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/batches/" <> batch_id <> "/remove_shipments"), conf[:key], [], ctype, body)
  end

end