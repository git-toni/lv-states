defmodule Demo.Data do
  alias Demo.Filter
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
    |> Enum.to_list
  end
  def fetch(filters) do
    load_data
    |> Filter.query_filter(filters)
  end
end
