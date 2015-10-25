defmodule Easypost.Tracker do 
  alias Easypost.Helpers
  alias Easypost.Requester

  defstruct [
    id: "",
    object: "Tracker",
    mode: "",
    tracking_code: "",
    status: "",
    created_at: "",
    updated_at: "",
    signed_by: "",
    weight: 0,
    est_delivery_date: "",
    shipment_id: "",
    carrier: "",
    tracking_details: []
  ]

  @type t :: %__MODULE__{
    id: String.t,
    object: String.t,
    mode: String.t,
    tracking_code: String.t,
    status: String.t,
    created_at: String.t,
    updated_at: String.t,
    signed_by: String.t,
    weight: number,
    est_delivery_date: String.t,
    shipment_id: String.t,
    carrier: String.t,
    tracking_details: list(map)
  }

  @spec track(map, map) :: Easypost.Tracker.t
  def track(conf, tracking) do
    body = Helpers.encode(%{"tracker" => tracking})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/trackers"), conf[:key], [], ctype, body) do
      {:ok, tracker}->
        {:ok, struct(Easypost.Tracker, tracker)}
      {:error, _status, reason}->
        {:error, struct(Easypost.Error, reason)}
    end
  end

end