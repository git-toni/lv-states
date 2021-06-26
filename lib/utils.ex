defmodule LvStates.Utils do
  def process_options(opts, :search) do
    if is_nil(opts) || opts == [], do: raise "Please specify the filter fields eg. 'use LvStates.WithSearch [:field1, :field2]'"
    opts
  end

  def key_atomize(k) do
    if is_binary(k), do: String.to_atom(k), else: k
  end
end
