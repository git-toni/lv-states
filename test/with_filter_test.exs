defmodule WithFilterTest do
  use ExUnit.Case
  doctest LvStates.WithSearch
  alias Phoenix.LiveView.Socket

  defmodule Filterable do
    use LvStates.WithFilter, [:brand, color: :multiple]
    def fetch(socket), do: socket
  end

  @state_key LvStates.WithFilter.state_key
  @starting_state  Filterable.lvs_filter_state_reset(%{})
  @target_single :brand
  @target_multiple :color
  @init_lvs_filters  @starting_state |> Map.get(@state_key)
  @starting_socket  %Socket{ assigns: @starting_state }

  test "lvs_filter_state_reset/1 populates state" do
    expected = %{
      @state_key => %{
        @target_single => %{value: nil, type: :single},
        @target_multiple => %{value: [], type: :multiple},
      }
    }
    assert Filterable.lvs_filter_state_reset(%{}) == expected
  end

  test "raise error when no fields provided" do
    assert_raise RuntimeError, ~r/^Please specify the filter fields/, fn ->
      defmodule FilterableError do
        use LvStates.WithFilter
      end
    end
  end

  test "handle_filter_clear/2 :single" do
    single_state = %{ Map.get(@init_lvs_filters, @target_single) | value: "lucid" }
    modified_initial_state = @init_lvs_filters |> Map.put(@target_single, single_state)

    starting_socket = %Socket{ assigns: %{ @state_key => modified_initial_state } }
    expected_socket = @starting_socket

    assert (
      Filterable.handle_filter_clear(starting_socket, @target_single).assigns
      ==
      expected_socket.assigns
    )
  end
  test "handle_filter_clear/2 :multiple" do
    target = @target_multiple
    fieldstate = %{ Map.get(@init_lvs_filters, target) | value: ["red", "blue"] }
    modified_initial_state = @init_lvs_filters |> Map.put(target, fieldstate)

    starting_socket = %Socket{ assigns: %{ @state_key => modified_initial_state } }
    expected_socket = @starting_socket

    assert (
      Filterable.handle_filter_clear(starting_socket, target).assigns
      == expected_socket.assigns
    )
  end

  test "handle_filter_clear_all/2" do
    target = @target_multiple
    fieldstate = %{ Map.get(@init_lvs_filters, target) | value: ["red", "blue"] }
    modified_initial_state = @init_lvs_filters |> Map.put(target, fieldstate)

    starting_socket = %Socket{ assigns: %{ @state_key => modified_initial_state } }
    expected_socket = @starting_socket

    assert (
      Filterable.handle_filter_clear_all(starting_socket).assigns
      == expected_socket.assigns
    )
  end
  # Reset all -> fields_reset
  # reset field -> reset_field
  # Remove value -> remove value if exists from "value"(eg pills' X button)
  # set field / set value -> if multiple, append; else overwrite


  # Remove
  # "tesla", remove "lucid" -> "tesla" when remove doesn't match
  # nil, remove "tesla" -> nil when state is nil
  # "tesla", remove "tesla" -> nil when matches
  test "handle_filter_remove/3 :single, when empty" do
    target = @target_single
    value = "tesla"

    starting_socket = @starting_socket
    expected_socket = @starting_socket

    assert (
      Filterable.handle_filter_remove(starting_socket, target, value).assigns
      == expected_socket.assigns
    )
  end
  test "handle_filter_remove/3 :single, when matching" do
    target = @target_single
    value = "tesla"
    field_state = %{ Map.get(@init_lvs_filters, target) | value: value }
    modified_lvs_state = @init_lvs_filters |> Map.put(target, field_state)

    starting_socket = %Socket{ assigns: %{ @state_key => modified_lvs_state } }
    expected_socket = @starting_socket
    assert (
      Filterable.handle_filter_remove(starting_socket, target, value).assigns
      == expected_socket.assigns
    )
  end
  test "handle_filter_remove/3 :single, when NOT matching" do
    target = @target_single
    value = "tesla"
    difvalue = "lucid"
    field_state = %{ Map.get(@init_lvs_filters, target) | value: value }
    modified_lvs_state = @init_lvs_filters |> Map.put(target, field_state)

    starting_socket = %Socket{ assigns: %{ @state_key => modified_lvs_state } }
    expected_socket = starting_socket
    assert (
      Filterable.handle_filter_remove(starting_socket, target, difvalue).assigns
      == expected_socket.assigns
    )
  end
  test "handle_filter_remove/3 :multiple, when empty" do
    target = @target_multiple
    value = "tesla"

    starting_socket = @starting_socket
    expected_socket = @starting_socket

    assert (
      Filterable.handle_filter_remove(starting_socket, target, value).assigns
      == expected_socket.assigns
    )
  end
  test "handle_filter_remove/3 :multiple, when matching" do
    target = @target_multiple
    value = "tesla"
    field_state = %{ Map.get(@init_lvs_filters, target) | value: [value] }
    modified_lvs_state = @init_lvs_filters |> Map.put(target, field_state)
    starting_socket = %Socket{ assigns: %{ @state_key => modified_lvs_state } }
    expected_socket = @starting_socket
    assert (
      Filterable.handle_filter_remove(starting_socket, target, value).assigns
      == expected_socket.assigns
    )
  end
  test "handle_filter_remove/3 :multiple, when NOT matching" do
    target = @target_multiple
    value = "tesla"
    difvalue = "lucid"
    field_state = %{ Map.get(@init_lvs_filters, target) | value: [value] }
    modified_lvs_state = @init_lvs_filters |> Map.put(target, field_state)
    starting_socket = %Socket{ assigns: %{ @state_key => modified_lvs_state } }
    expected_socket = starting_socket
    assert (
      Filterable.handle_filter_remove(starting_socket, target, difvalue).assigns
      == expected_socket.assigns
    )
  end

  # SET_FIELD
  test "handle_filter_set/3 :single" do
    target = @target_single
    value = "tesla"

    field_state = %{ Map.get(@init_lvs_filters, target) | value: value }
    modified_lvs_state = @init_lvs_filters |> Map.put(target, field_state)

    starting_socket = @starting_socket
    expected_socket = %Socket{ assigns: %{ @state_key => modified_lvs_state } }
    assert (
      Filterable.handle_filter_set(starting_socket, target, value).assigns
      == expected_socket.assigns
    )
  end

  test "handle_filter_set/3 :multiple, checks uniqueness" do
    target = @target_multiple
    value = "red"

    field_state = %{ Map.get(@init_lvs_filters, target) | value: [value] }
    modified_lvs_state = @init_lvs_filters |> Map.put(target, field_state)

    starting_socket = @starting_socket
    expected_socket = %Socket{ assigns: %{ @state_key => modified_lvs_state } }
    result =
      starting_socket
      |> Filterable.handle_filter_set(target, value)
      |> Filterable.handle_filter_set(target, value)
    assert (
      result.assigns
      == expected_socket.assigns
    )
  end
end
