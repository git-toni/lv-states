defmodule LvStates.WithFilter do
  @moduledoc """
  `LvStates.WithFilter` stores any number of multi-value or single-value state keys that you choose
  inside the `:lvs_filters` namespace.

  It is useful when we want to filter our data based on a fixed set of values/categories.
  Using the `LvStates.WithFilter` macro will have two consequences for our `LiveView.Socket`:
  1) It populates `:lvs_filters` with a map for each of your filterable keys.

  2) A few event handles are generated to manipulate the state of your filters.

  ```
    # In case of :multiple, it adds the value to the specified filter. In case of :single filter, it overwrites the current value
    def handle_event("lvs-filter-set", %{"field" => field, "value" => value}, %Socket{} = socket) do
  ```

  ```
    # Removes the value of a particular filter from the state
    def handle_event("lvs-filter-remove", %{"field" => field, "value" => value}, %Socket{} = socket) do
  ```

  ```
    # Clears all values from a particular filter, both for :single and :multiple filters.
    def handle_event("lvs-filter-clear", %{"field" => field}, %Socket{} = socket) do
  ```

  ```
    # Clears all values from all filters under the :lvs_filters namespace
    def handle_event("lvs-filter-clear-all", _, %Socket{} = socket) do
  ```

  And lastly an indirect consequence is that `LvStates.WithSearch` assumes that our `LiveView` implements the following method:
  ```
    def fetch(%LiveView.Socket{})
  ```

  **Note**: if the assumed `fetch/1` function is not implemented the functionality will not work as expected.

  ## Examples

      defmodule CarInventory do
        use LvStates.WithSearch, [:model]
      end
  """
  import LvStates.Utils
  alias Phoenix.LiveView.Socket
  alias Phoenix.LiveView

  #@initial_state %{}
  @single_field_initial_state %{
    value: nil,
    type: :single,
  }
  @multiple_field_initial_state %{
    value: [],
    type: :multiple,
  }
  @state_key :lvs_filters

  @doc false
  def single_field_initial_state, do: @single_field_initial_state
  def multiple_field_initial_state, do: @multiple_field_initial_state

  @doc false
  def state_key, do: @state_key

  defmacro __using__(opts) do

    opts = opts |> process_options(:filters)
    escaped_opts = opts |> Macro.escape

    static = quote do
      def lvs_filter_state_reset(%{} = fields \\ %{}) do
        opts = unquote(escaped_opts)
        state_key = unquote(@state_key)
        reset_fields = opts |> Enum.reduce(%{}, fn({k,v}, acc) ->
          reset_val = if v == :single,
            do: LvStates.WithFilter.single_field_initial_state,
            else: LvStates.WithFilter.multiple_field_initial_state
          Map.put(acc, k, reset_val)
        end)

        fields
        |> Map.put(state_key, reset_fields)

      end
      def handle_filter_clear(%Socket{} = socket, field) do
        state_key = unquote(@state_key)
        field = if is_binary(field), do: String.to_atom(field), else: field
        reset_val = case Kernel.get_in(socket.assigns, [state_key, field, :type]) do
          :single -> LvStates.WithFilter.single_field_initial_state
          :multiple -> LvStates.WithFilter.multiple_field_initial_state
        end
        socket
        |> LvStates.Utils.socket_set_field(unquote(@state_key), field, reset_val)
      end
      def handle_filter_remove(%Socket{} = socket, field, value) do
        state_key = unquote(@state_key)
        field = if is_binary(field), do: String.to_atom(field), else: field
        field_type = Kernel.get_in(socket.assigns, [state_key, field, :type])
        if is_nil(field_type) do
          raise "Can't detect field type"
        end
        socket
        |> update_field(:remove, field, field_type, value)
      end
      def handle_filter_set(%Socket{} = socket, field, value) do
        state_key = unquote(@state_key)
        field = if is_binary(field), do: String.to_atom(field), else: field
        field_type = Kernel.get_in(socket.assigns, [state_key, field, :type])
        if is_nil(field_type) do
          raise "Can't detect field type"
        end

        socket
        |> update_field(:set, field, field_type, value)
      end
      def handle_filter_clear_all(%Socket{} = socket) do
        state_key = unquote(@state_key)

        socket
        |> LiveView.assign(lvs_filter_state_reset())
      end

      def update_field(%Socket{} = socket, action, field, type, value)
        when action == :remove and type == :single
      do
        state_key = unquote(@state_key)
        current = socket |> LvStates.Utils.socket_get_field(unquote(@state_key), field)
        cond do
          is_nil(current) ->
            socket
          current == value ->
            reset_val = LvStates.WithFilter.single_field_initial_state
            socket |> LvStates.Utils.socket_set_field(state_key, field, reset_val)
          true ->
            socket
        end
      end
      def update_field(%Socket{} = socket, action, field, type, value)
        when action == :remove and type == :multiple
      do
        state_key = unquote(@state_key)
        current = socket |> LvStates.Utils.socket_get_field(unquote(@state_key), field)
        cond do
          length(current) == 0 ->
            socket
          is_binary(Enum.find(current, &(&1 == value))) ->
            reset_state = LvStates.WithFilter.multiple_field_initial_state
            new_val = current |> List.delete(value)
            reset_state = %{reset_state | value: new_val}
            socket |> LvStates.Utils.socket_set_field(state_key, field, reset_state)
          true ->
            socket
        end
      end

      def update_field(%Socket{} = socket, action, field, type, value)
        when action == :set and type == :single
      do
        state_key = unquote(@state_key)
        current = socket |> LvStates.Utils.socket_get_field(unquote(@state_key), field)
        new_val = %{ LvStates.WithFilter.single_field_initial_state | value: value}

        socket
        |> LvStates.Utils.socket_set_field(state_key, field, new_val)
      end
      def update_field(%Socket{} = socket, action, field, type, value)
        when action == :set and type == :multiple
      do
        state_key = unquote(@state_key)
        current = socket |> LvStates.Utils.socket_get_field(unquote(@state_key), field)
        new_val = (current ++ [value] ) |> Enum.uniq
        new_state = %{ LvStates.WithFilter.multiple_field_initial_state | value: new_val}
        socket
        |> LvStates.Utils.socket_set_field(state_key, field, new_state)
      end
      def handle_event("lvs-filter-set", %{"field" => field, "value" => value}, %Socket{} = socket) do
        IO.puts("hooooli field: #{field} value: #{value}")
        socket = socket |> handle_filter_set(field, value)
        fetch(socket)
        {:noreply, socket}
      end
      def handle_event("lvs-filter-remove", %{"field" => field, "value" => value}, %Socket{} = socket) do
        socket = socket |> handle_filter_remove(field, value)
        fetch(socket)
        {:noreply, socket}
      end
      def handle_event("lvs-filter-clear", %{"field" => field}, %Socket{} = socket) do
        socket = socket |> handle_filter_clear(field)
        fetch(socket)
        {:noreply, socket}
      end
      def handle_event("lvs-filter-clear-all", _, %Socket{} = socket) do
        socket = socket |> handle_filter_clear_all()
        fetch(socket)
        {:noreply, socket}
      end
    end

    [static]
  end
end
