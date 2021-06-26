defmodule LvStates.WithSearch do
  import LvStates.Utils
  alias Phoenix.LiveView.Socket

  @initial_state %{
    searching: false,
    query: nil,
  }
  @state_key :search

  def initial_state, do: @initial_state
  def state_key, do: @state_key

  defmacro __using__(opts) do

    opts = opts |> process_options(:search)

    static = quote bind_quoted: [
      state_key: @state_key, 
      opts: opts,
      initial_state: Macro.escape(@initial_state)
      ] do
      def search_fields_reset(%{} = parent_state) do
        reset_fields = unquote(opts) 
                       |> Enum.reduce(%{}, 
                         fn(x, acc) -> 
                           Map.put(acc, x, unquote(Macro.escape(initial_state)))
                         end)
        parent_state |> Map.put(unquote(state_key), reset_fields) 
      end
      def set_field(%Socket{} = socket, field, new_value) do
        field = LvStates.Utils.key_atomize(field)
        socket
        |> Kernel.put_in([
          Access.key(:assigns, %{}), 
          Access.key(unquote(state_key), %{}),
          Access.key(field, %{})], 
          new_value
        )
      end
      def set_query(%Socket{} = socket, field, query) do
        new_search_field = %{searching: true, query: query}
        socket 
        |> set_field(field, new_search_field)
      end
      def reset_query(socket, field) do
        new_value = %{searching: false, query: nil}
        socket 
        |> set_field(field, new_value)
      end
    end

    dynamic = opts
              |> Enum.map(fn field ->
                # handle_event expects string not atom
                field = Atom.to_string(field)
                quote do
                    def handle_event(
                      "search-"<> unquote(field),
                      %{"query" => query},
                      %Socket{} = socket
                    )
                    when byte_size(query) == 0 do
                      socket = socket |> reset_query(unquote(field))
                      {:noreply, socket}
                    end
                    def handle_event(
                      "search-"<> unquote(field),
                      %{"query" => query},
                      %Socket{} = socket
                    )
                    when is_nil(query) do
                      socket = socket |> reset_query(unquote(field))
                      {:noreply, socket}
                    end
                    def handle_event(
                      "search-"<> unquote(field),
                      %{"query" => query},
                      %Socket{} = socket
                    )
                     do
                      socket = socket |> set_query(unquote(field), query)
                      {:noreply, socket}
                    end

                  end
                end)

    [static, dynamic]
  end
end
