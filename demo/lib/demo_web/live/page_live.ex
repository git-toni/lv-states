defmodule DemoWeb.PageLive do
  use DemoWeb, :live_view
  use LvStates.WithSearch, [:main_query]
  use LvStates.WithFilter, [brand: :multiple]
  alias Phoenix.LiveView
  alias Phoenix.LiveView.Socket
  alias DemoWeb.LayoutView

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(reset_fields)
      |> assign(:brands, Demo.Data.read_brands())
      |> assign(:selected_car, initial_selected_state())
    socket = LiveView.assign_new(socket, :results, fn -> Demo.Data.fetch(socket) end)


    {:ok, socket}
  end
  def render(assigns), do: LayoutView.render("page_live.html", assigns)

  def reset_fields do
    %{}
    |> search_fields_reset # injected by WithSearch
    |> lvs_filter_state_reset # injected by WithFilter
  end
  def initial_selected_state do
    %{
      data: nil,
      is_fetching: false,
    }
  end
  def handle_event("close-car", _, socket) do
    socket = socket |> assign(:selected_car, initial_selected_state())
    {:noreply, socket}
  end
  def handle_event("select-car", %{"car_id" => car_id},
    %Socket{ assigns: %{results: results, selected_car: selected_car}} = socket)
    do
    car_id = String.to_integer(car_id)
    car = results |> Enum.find(fn r -> r.id == car_id end)
    #IO.inspect(car, label: "hellocar")
    selected_car =
      selected_car
      |> Map.put(:is_fetching, true)
      |> Map.put(:data, car)
    socket = socket |> assign(:selected_car, selected_car)
    {:noreply, socket}
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
