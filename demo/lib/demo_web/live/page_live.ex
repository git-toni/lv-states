defmodule DemoWeb.PageLive do
  use DemoWeb, :live_view
  use LvStates.WithSearch, [:main_query]
  use LvStates.WithFilter, [brand: :multiple]
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(reset_fields)
      |> assign(:brands, Demo.Data.read_brands())
    socket = LiveView.assign_new(socket, :results, fn -> Demo.Data.fetch(socket) end)


    {:ok, socket}
  end

  def reset_fields do
    %{}
    |> search_fields_reset # injected by WithSearch
    |> lvs_filter_state_reset # injected by WithFilter
  end

  # Fetch Logic
  def fetch(%Socket{} = socket) do
    results = Demo.Data.fetch(socket)
    send self(), {:fetched, results}
  end

  def handle_info({:fetched, results}, socket) do
    socket = assign(socket, %{results: results})
    {:noreply, socket}
  end
end
