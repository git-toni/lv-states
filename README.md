![CI/CD](https://github.com/git-toni/lv-states/actions/workflows/main.yml/badge.svg)
[![Hex.pm](https://img.shields.io/hexpm/v/lv_states.svg?color=blue)]()
# Lv-States

**lv-states** (short for LiveView States) provides a handful of state management helpers for [Phoenix LiveView Sockets](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Socket.html) with the aim of simplifying common needs of client <> server communication present in interactive applications.

See it in action at [https://lv-states.fly.dev](https://lv-states.fly.dev)

### Documentation
Read the full documentation at https://hexdocs.pm/lv_states/

### Installation

```elixir
def deps do
  [
    {:lv_states, "~> 0.1.1"}
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

## WithFilter

Useful for multi-value fields.

### Usage

```elixir
defmodule CarInventory do
  use LvStates.WithFilter, [brand: :multiple]
  #...rest of functions
end
```
Send events from a collection of options to the event handler like this:

```leex
<%= for b <- @brands do %>
  <div
    phx-click="lvs-filter-set"
    phx-value-field="brand"
    phx-value-value="<%= b %>"
    >
    <%= b %>
  </div>
<% end %> %>
```

For a full example please see the source of the [demo](/demo)

## TODO
- Migrate phoenix demo app to esbuild
- Use Utils.socket_set_field for WithSearch helper
- Create test utils functions to obtain useful structs
- Check that values added are binary not nil
- Compilation-time check that "fetch" or dynamic fetcher function exists in the host module