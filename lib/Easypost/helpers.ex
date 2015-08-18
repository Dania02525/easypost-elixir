defmodule Easypost.Client.Helpers do

  def url(domain, path), do: Path.join([domain, path])

  def encode(map) do
    map
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

end