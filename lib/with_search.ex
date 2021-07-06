defmodule LvStates.WithSearch do
  @moduledoc """
  `LvStates.WithSearch` adds a **:search** subset of state
  to the main `LiveView.Socket`.

  It is useful in situations where we want our application to
  query our data most typically stemming from a client search input.
  Using the `LvStates.WithSearch` macro will have two consequences for our `LiveView.Socket`:
  1) It is populated with a `:search` field containing `%{searching: false, query: nil}`.

  2) A new event handler is generated:
  ```
    def handle_event("search-model", %{"query" => query}, socket)
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

  @initial_state %{
    searching: false,
    query: nil,
  }
  @state_key :search

  @doc false
  def initial_state, do: @initial_state
  @doc false
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
        oldGlobal = 
          socket
          |> Kernel.get_in([
            Access.key(:assigns, %{}), 
            Access.key(unquote(state_key), %{})
          ])
        newGlobal = 
          oldGlobal 
          |> Kernel.put_in([
            Access.key(field, %{})
          ], new_value)


        socket
        |> LiveView.assign(unquote(state_key), newGlobal)
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
                      fetch(socket)
                      {:noreply, socket}
                    end
                    def handle_event(
                      "search-"<> unquote(field),
                      %{"query" => query},
                      %Socket{} = socket
                    )
                    when is_nil(query) do
                      socket = socket |> reset_query(unquote(field))
                      fetch(socket)
                      {:noreply, socket}
                    end
                    def handle_event(
                      "search-"<> unquote(field),
                      %{"query" => query},
                      %Socket{} = socket
                    )
                     do
                      socket = socket |> set_query(unquote(field), query)
                      fetch(socket)
                      {:noreply, socket}
                    end

                  end
                end)

    [static, dynamic]
  end
end
