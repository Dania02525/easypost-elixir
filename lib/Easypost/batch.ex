defmodule Easypost.Batch do 
  alias Easypost.Helpers
  alias Easypost.Requester

  defstruct {
    id: "",
    object: "Batch",
    shipments: [],
    status: %{},
    label_url: "",
    created_at: "",
    updated_at: ""
  }

  @type t :: %__MODULE__{
    id: String.t,
    object: String.t,
    shipments: list(Easypost.Shipment),
    status: map,
    label_url: String.t,
    created_at: String.t,
    updated_at: String.t
  }

  @spec create_batch(map, list) :: Easypost.Batch.t
  def create_batch(conf, shipments) do
    body = Helpers.encode(%{"batch" => shipments})
    ctype = 'application/x-www-form-urlencoded'

    
    case Requester.request(:post, Helpers.url(conf[:endpoint], "/batches"), conf[:key], [], ctype, body) do
      {:ok, batch}->
        struct(Easypost.Batch, batch)
      {:error, status, reason}->
        "Error: " <> status <> reason
    end
  end

  @spec create_and_buy(map, list) :: Easypost.Batch.t
  def create_and_buy_batch(conf, shipments) do
    body = Helpers.encode(%{"batch" => shipments})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/batches/create_and_buy"), conf[:key], [], ctype, body) do
      {:ok, batch}->
        struct(Easypost.Batch, batch)
      {:error, status, reason}->
        "Error: " <> status <> reason
    end
  end

  @spec batch_labels(map, String.t, map) :: Easypost.Batch.t
  def batch_labels(conf, batch_id, label) do
    body = Helpers.encode(label)
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/batches/" <> batch_id <> "/label"), conf[:key], [], ctype, body) do
      {:ok, batch}->
        struct(Easypost.Batch, batch)
      {:error, status, reason}->
        "Error: " <> status <> reason
    end
  end

  @spec add_to_batch(map, String.t, list) :: Easypost.Batch.t
  def add_to_batch(conf, batch_id, shipments) do
    body = Helpers.encode(%{"shipments" => shipments})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/batches/" <> batch_id <> "/add_shipments"), conf[:key], [], ctype, body) do
      {:ok, batch}->
        struct(Easypost.Batch, batch)
      {:error, status, reason}->
        "Error: " <> status <> reason
    end
  end

  @spec remove_from_batch(map, String.t, list) :: Easypost.Batch.t
  def remove_from_batch(conf, batch_id, shipments) do
    body = Helpers.encode(%{"shipments" => shipments})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/batches/" <> batch_id <> "/remove_shipments"), conf[:key], [], ctype, body) do
      {:ok, batch}->
        struct(Easypost.Batch, batch)
      {:error, status, reason}->
        "Error: " <> status <> reason
    end
  end

end