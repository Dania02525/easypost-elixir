defmodule Easypost.Client.Customs do 
  alias Easypost.Client.Helpers
  alias Easypost.Client.Requester

  def create_customs_forms(conf, customs_info) do
    body = Helpers.encode(%{"customs_info" => customs_info})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/customs_infos"), conf[:key], [], ctype, body)
  end

end