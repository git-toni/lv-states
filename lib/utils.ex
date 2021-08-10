defmodule LvStates.Utils do
  alias Phoenix.LiveView.Socket
  alias Phoenix.LiveView

  def process_options(opts, :search) do
    if is_nil(opts) || opts == [], do: raise "Please specify the filter fields eg. 'use LvStates.WithSearch [:field1, :field2]'"
    opts
  end
  def process_options(opts, :filters) do
    if is_nil(opts) || opts == [],
      do: raise "Please specify the filter fields eg. 'use LvStates.WithFilter [:field1, field2: :multiple]'"

    opt_pairs =
      opts
      |> Enum.into(%{}, fn e ->
        if is_tuple(e), do: {elem(e,0),elem(e,1)}, else: {e, :single}
      end)
    opt_pairs
  end
  def key_atomize(k) do
    if is_binary(k), do: String.to_atom(k), else: k
  end
  def socket_set_field(%Socket{} = socket, lvs_space, field, new_value) do
    field = LvStates.Utils.key_atomize(field)
    oldGlobal =
      socket
      |> Kernel.get_in([
        Access.key(:assigns, %{}),
        Access.key(lvs_space, %{})
      ])
    newGlobal =
      oldGlobal
      |> Kernel.put_in([
        Access.key(field, %{})
      ], new_value)


    socket
    |> LiveView.assign(lvs_space, newGlobal)

  end
  def socket_get_field(%Socket{} = socket, lvs_space, field) do
    field = LvStates.Utils.key_atomize(field)
    socket
    |> Kernel.get_in([
      Access.key(:assigns, %{}),
      Access.key(lvs_space, %{}),
      Access.key(field, %{}),
      Access.key(:value, nil),
    ])
  end
end
