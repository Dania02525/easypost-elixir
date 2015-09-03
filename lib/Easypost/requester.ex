defmodule Easypost.Requester do

  def request(method, url, key, headers, ctype, body) do
    url = String.to_char_list(url)
    case method do
      :get ->
        headers = headers ++ [auth_header(key)]
        :httpc.request(:get, {url, headers}, [], [])
      _ ->
        headers = headers ++ [auth_header(key), {'Content-Type', ctype}]
        :httpc.request(method, {url, headers, ctype, body}, [], body_format: :binary)
    end 
    |> parse_response

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
        {:error, status, Poison.decode!(json_body) |> Easypost.Helpers.cast_keys}
      {:ok, {{_httpvs, status, _status_phrase}, _headers, json_body}} ->
        {:error, status, Poison.decode!(json_body) |> Easypost.Helpers.cast_keys}
      {:error, reason} -> 
        {:error, :bad_fetch, %{"code" => "bad fetch", "message" => reason} |> Easypost.Helpers.cast_keys}
    end
  end

end