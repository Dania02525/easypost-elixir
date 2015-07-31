defmodule Easypost.Client.Tracker do 
  alias Easypost.Client.Helpers
  alias Easypost.Client.Requester

  def track(conf, tracking) do
    body = Helpers.encode(%{tracker: tracking})
    ctype = 'application/x-www-form-urlencoded'

    Requester.request(:post, Helpers.url(conf[:endpoint], "/trackers"), conf[:key], [], ctype, body)
  end

end