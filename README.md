![CI/CD](https://github.com/git-toni/lv-states/actions/workflows/main.yml/badge.svg)
[![Hex.pm](https://img.shields.io/hexpm/v/lv_states.svg?color=blue)]()
# Lv-States

**lv-states** (short for LiveView States) provides a handful of state management helpers for [Phoenix LiveView Sockets](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Socket.html) with the aim of simplifying common needs of client <> server communication present in interactive applications.

See it in action at [https://lv-states.fly.dev](https://lv-states.fly.dev)

### Installation

```elixir
def deps do
  [
    {:lv_states, "~> 0.1.0"}
  ]
end
```

## WithSearch

Useful for those situations in which a search is present in the UI. 

### Usage

```elixir
defmodule CarInventory do
  use LvStates.WithSearch, [:model]
  #...rest of functions
end
```

The use of `LvStates.WithSearch` in this case has two consequences:

1. The *LiveView.Socket* is populated with a new Map `search`.
```elixir
%LiveView.Socket: %{
  assigns: %{
    #...
    search: %{
      model: %{
        searching: false,
        query: nil,
      }
    }
  }
}
```

2. A new event handler is added to the client module (ie `CarInventory`)

```elixir
def handle_event("search-model", %{"query" => query}, socket), do:...
```

You can now comfortably point your client events to the new event handler, Eg.
```leex
  <form phx-change="search-model">
    <input
      type="text"
      name="query"
      phx-debounce="300"
      value="<%= @search.model.query %>"
      placeholder="Insert the model name to search">
  </form>
```

For a full example please see the source of the [demo](/demo)


