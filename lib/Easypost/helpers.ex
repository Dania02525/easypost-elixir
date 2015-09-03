defmodule Easypost.Helpers do

  def url(domain, path), do: Path.join([domain, path])

  def encode(map) do
    q = map
      |> Enum.map(fn({k,v})-> process(k, v) end)
      |> List.flatten
      |> URI.encode_query
  end

  def process(acc, v) when is_map(v) do
    v 
    |> Enum.map(fn({k, v})-> process(acc <> "[" <> k <> "]", v) end)
  end

  def process(acc, v) when is_list(v) do
    v 
    |> Enum.with_index
    |> Enum.map(fn({v, i})-> process(acc <> "[" <> Integer.to_string(i) <> "]", v) end)
  end

  def process(acc, v) do
    {acc, v}
  end

  def cast_keys(map) do
    map |> Enum.map(fn(x)-> cast(x) end)
  end

  def cast({k, v}) when is_map(v) do
    {String.to_atom(k), put_struct(v)}
  end

  def cast({k, v}) when is_list(v) do
    val = v 
    |> Enum.map(fn 
      x when is_map(x)-> put_struct(x)
      x -> cast(x)
      end)
    {String.to_atom(k), val}
  end

  def cast({k, v}) do
    {String.to_atom(k), v}
  end

  defp put_struct(v) do
    case v["object"] do
      "Address" ->
        struct(Easypost.Address, v |>  Enum.map(fn(x)-> cast(x) end))
      "Batch" ->
        struct(Easypost.Batch, v |>  Enum.map(fn(x)-> cast(x) end))
      "CarrierAccount" ->
        struct(Easypost.CarrierAccount, v |>  Enum.map(fn(x)-> cast(x) end))
      "CustomsInfo" ->
        struct(Easypost.CustomsInfo, v |>  Enum.map(fn(x)-> cast(x) end))
      "CustomsItem" ->
        struct(Easypost.CustomsItem, v |>  Enum.map(fn(x)-> cast(x) end))
      "Parcel" ->
        struct(Easypost.Parcel, v |>  Enum.map(fn(x)-> cast(x) end))
      "PickupRate" ->
        struct(Easypost.PickupRate, v |>  Enum.map(fn(x)-> cast(x) end))
      "PostageLabel" ->
        struct(Easypost.PostageLabel, v |>  Enum.map(fn(x)-> cast(x) end))
      "Rate" ->
        struct(Easypost.Rate, v |>  Enum.map(fn(x)-> cast(x) end))
      "Refund" ->
        struct(Easypost.Refund, v |>  Enum.map(fn(x)-> cast(x) end))
      "Shipment" ->
        struct(Easypost.Shipment, v |>  Enum.map(fn(x)-> cast(x) end))
      "Tracker" ->
        struct(Easypost.Tracker, v |>  Enum.map(fn(x)-> cast(x) end))
      "User" ->
        struct(Easypost.User, v |>  Enum.map(fn(x)-> cast(x) end))
      _ ->
        v |> Enum.map(fn(x)-> cast(x) end)
    end
  end

end