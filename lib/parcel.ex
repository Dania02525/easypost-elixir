defmodule Easypost.Client.Parcel do 
  alias Easypost.Client.Helpers
  alias Easypost.Client.Requester

  def create_parcel(conf, parcel) do  
    body = Helpers.encode(%{parcel: parcel})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/parcels"), conf[:key], [], ctype, body)
  end

end