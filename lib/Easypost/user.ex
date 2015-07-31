defmodule Easypost.Client.User do 
  alias Easypost.Client.Helpers
  alias Easypost.Client.Requester

  def get_child_api_keys(conf) do
    body = []
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:get, Helpers.url(conf[:endpoint], "/api_keys"), conf[:key], [], ctype, body)
  end

  def add_carrier_account(conf, carrier) do
    body = Helpers.encode(%{carrier_account: carrier})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/carrier_accounts"), conf[:key], [], ctype, body)
  end

  def create_user(conf, user) do
    body = Helpers.encode(%{user: user})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/users"), conf[:key], [], ctype, body)
  end

end