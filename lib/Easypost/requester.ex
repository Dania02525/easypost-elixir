defmodule Easypost.Requester do

  def request(method, url, key, headers, ctype, body) do
    url = String.to_char_list(url)
    fetch = case method do
      :get ->
        headers = headers ++ [auth_header(key)]
        Task.async(fn-> :httpc.request(:get, {url, headers}, [], []) end)
      _ ->
        headers = headers ++ [auth_header(key), {'Content-Type', ctype}]
        Task.async(fn-> :httpc.request(method, {url, headers, ctype, body}, [], body_format: :binary) end)
    end 

    try do
      Task.await(fetch, 10000)
      |> parse_response
    catch :exit,
      _-> {:error, "UNAVAILABLE", %{code: "UNAVAILABLE", message: "The service is currently unavaible.  Please try again later."}}
    end
  end

  defp auth_header(key) do
  {'Authorization', 'Basic ' ++ String.to_char_list(Base.encode64(key <> ":"))}
  end

  defp parse_response(response) do
    case response do
      {:ok, {{_httpvs, 200, _status_phrase}, json_body}} ->
        {:ok, Poison.decode!(json_body) |> Easypost.Helpers.cast_keys}
      {:ok, {{_httpvs, 201, _status_phrase}, json_body}} ->
        {:ok, Poison.decode!(json_body) |> Easypost.Helpers.cast_keys}
      {:ok, {{_httpvs, 200, _status_phrase}, _headers, json_body}} ->
        {:ok, Poison.decode!(json_body) |> Easypost.Helpers.cast_keys}
      {:ok, {{_httpvs, 201, _status_phrase}, _headers, json_body}} ->
        {:ok, Poison.decode!(json_body) |> Easypost.Helpers.cast_keys}
      {:ok, {{_httpvs, status, _status_phrase}, json_body}} ->
        {:error, status, Poison.decode!(json_body)["error"] |> Easypost.Helpers.cast_keys}
      {:ok, {{_httpvs, status, _status_phrase}, _headers, json_body}} ->
        {:error, status, Poison.decode!(json_body)["error"] |> Easypost.Helpers.cast_keys}
      {:error, reason} -> 
        {:error, :bad_fetch, %{"code" => "bad fetch", "message" => reason} |> Easypost.Helpers.cast_keys}
    end
  end

end