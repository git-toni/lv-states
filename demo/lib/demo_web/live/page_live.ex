defmodule DemoWeb.PageLive do
  use DemoWeb, :live_view
  use LvStates.WithSearch, [:main_query]
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  @impl true
  def mount(_params, _session, socket) do
    socket = 
      socket 
      |> assign(reset_fields)
      |> LiveView.assign_new(:results, fn -> Demo.Data.fetch(%{query: nil}) end)


    {:ok, socket}
  end

  def reset_fields do
    %{}
    |> search_fields_reset # injected by WithSearch
  end

  # Fetch Logic
  def fetch(%Socket{assigns: 
    %{search: 
      %{main_query: main_query}
    }
    } = socket) do
    new_query = main_query.query
    results = Demo.Data.fetch(%{query: new_query})
    send self(), {:fetched, results}
  end

  def handle_info({:fetched, results}, socket) do
    socket = assign(socket, %{results: results})
    {:noreply, socket}
  end
end
