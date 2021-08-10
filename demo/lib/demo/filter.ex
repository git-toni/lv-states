defmodule Demo.Filter do
  @moduledoc """
  Demo.Filter provides functions that
  """
  def query_filter(data, %{query: query}) when byte_size(query) == 0 do
    data
  end
  def query_filter(data, %{query: query}) when is_nil(query) do
    data
  end
  def query_filter(data, %{query: query}) do
    data
    |> Enum.filter(
      fn i -> i."Model" =~ ~r/#{query}/i
    end)
  end

  def brand_filter(data, nil), do: data
  def brand_filter(data, %{ value: [], type: :multiple}), do: data
  def brand_filter(data, %{ value: value, type: :multiple}) do
    data
    |> Enum.filter( fn i -> i."Brand" =~ ~r/#{value}/i end)
  end
end
