defmodule Easypost.Parcel do 
  alias Easypost.Helpers
  alias Easypost.Requester

  defstruct [
    id: "",
    object: "Parcel",
    length: 0,
    width: 0,
    height: 0,
    predefined_package: "",
    weight: 0,
    created_at: "",
    updated_at: ""
  ]

  @type t :: %__MODULE__{
    id: String.t,
    object: String.t,
    length: number,
    width: number,
    height: number,
    predefined_package: String.t,
    weight: number,
    created_at: String.t,
    updated_at: String.t
  }

  @spec create_parcel(map, map) :: Easypost.Parcel.t
  def create_parcel(conf, parcel) do  
    body = Helpers.encode(%{"parcel" => parcel})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/parcels"), conf[:key], [], ctype, body) do
      {:ok, parcel}->
        {:ok, struct(Easypost.Parcel, parcel)}
      {:error, _status, reason}->
        {:error, struct(Easypost.Error, reason)}
    end
  end

end