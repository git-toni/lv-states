defmodule Demo.Data do
  alias Demo.Filter
  alias Phoenix.LiveView.Socket
  @moduledoc """
  Demo.Data provides with example browseable data.
  """
  def key_atomize(k) do
    if is_binary(k), do: String.to_atom(k), else: k
  end
  def atomize(item) do
    item |> Map.new(fn {k, v} -> {(if is_binary(k), do: String.to_atom(k), else: k), v} end)
  end
  def load_data do
    "evdata.csv"
    |> Path.expand(__DIR__)
    |> File.stream!
    |> CSV.decode!(headers: true)
    |> Stream.map(&atomize/1)
    |> Stream.with_index()
    |> Stream.map(fn {v, i} -> Map.put(v, :id, i) end)
    |> Enum.to_list
  end
  def fetch(%Socket{} = socket) do
    query = socket.assigns.search.main_query
    brand_filter = socket.assigns.lvs_filters.brand
    load_data
    |> Filter.query_filter(query)
    |> Filter.brand_filter(brand_filter)
  end
  def read_brands do
    Enum.map(load_data, &(&1."Brand"))
    |> Enum.uniq
  end
end
