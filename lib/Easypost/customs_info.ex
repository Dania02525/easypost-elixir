defmodule Easypost.CustomsInfo do 
  alias Easypost.Helpers
  alias Easypost.Requester

  defstruct [
    id: "",
    object: "CustomsInfo",
    contents_explanation: "",
    contents_type: "",
    customs_certify: false,
    customs_signer: "",
    eel_pfc: "",
    non_delivery_option: "",
    restriction_comments: "",
    restriction_type: "",
    customs_items: [],
    created_at: "",
    updated_at: ""
  ]

  @type t :: %__MODULE__{
    id: String.t,
    object: String.t,
    contents_explanation: String.t,
    contents_type: String.t,
    customs_certify: boolean,
    customs_signer: String.t,
    eel_pfc: String.t,
    non_delivery_option: String.t,
    restriction_comments: String.t,
    restriction_type: String.t,
    customs_items: list(Easypost.CustomsItem),
    created_at: String.t,
    updated_at: String.t
  }

  @spec create_customs_info(map, map) :: Easypost.CustomsInfo.t
  def create_customs_info(conf, customs_info) do
    body = Helpers.encode(%{"customs_info" => customs_info})
    ctype = 'application/x-www-form-urlencoded'

    case Requester.request(:post, Helpers.url(conf[:endpoint], "/customs_infos"), conf[:key], [], ctype, body) do
      {:ok, info}->
        {:ok, struct(Easypost.CustomsInfo, info)}
      {:error, _status, reason}->
        {:error, struct(Easypost.Error, reason)}
    end
  end

end