defmodule Easypost.Client.Address do
  alias Easypost.Client.Helpers
  alias Easypost.Client.Requester

  def create_address(conf, address) do  
    body = Helpers.encode(%{address: address})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/addresses"), conf[:key], [], ctype, body)
  end

end