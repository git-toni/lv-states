defmodule WithSearchTest do
  use ExUnit.Case
  doctest LvStates.WithSearch
  alias Phoenix.LiveView.Socket

  defmodule Searchable do
    use LvStates.WithSearch, [:username]
    def fetch(socket), do: socket
  end

  @initial_state LvStates.WithSearch.initial_state
  @state_key LvStates.WithSearch.state_key
  @test_socket  %Socket{ assigns: %{ @state_key => %{}}}
  @target "username"

  test "search_fields_reset/1 populates state" do
    #IO.inspect(LvStates.WithSearch.initial_state)
    assert Searchable.search_fields_reset(%{}) == 
      %{@state_key =>  %{ username: @initial_state} }
  end

  test "raise error when no fields provided" do
    assert_raise RuntimeError, ~r/^Please specify the filter fields/, fn ->
      defmodule SearchableError do
        use LvStates.WithSearch
      end
    end
  end

  test "set_query/3 modifies internal state" do
    query = "content"
    expected = %Socket{ assigns: %{ 
      @state_key => 
        %{username: %{searching: true, query: query}}
      }
    }
    assert Searchable.set_query(@test_socket, @target, query).assigns == expected.assigns
  end

  test "reset_query/2" do
    expected = %Socket{ assigns: %{ 
      @state_key => 
        %{username: %{searching: false, query: nil}}
      }
    }
    assert Searchable.reset_query(@test_socket, @target).assigns == expected.assigns
  end

  test "handle_event(\"search-\") when query == 0" do
    query = nil
    expected = %Socket{ assigns: %{ 
      @state_key => 
        %{username: %{searching: false, query: nil}}
      },
      changed: %{ @state_key => @test_socket.assigns[@state_key] }
    }
    assert Searchable.handle_event("search-#{@target}", %{"query" => query}, @test_socket) 
    == {:noreply, expected}
  end
  test "handle_event(\"search-\")" do
    query = "testquery"
    expected = %Socket{ assigns: %{ 
      @state_key => 
        %{username: %{searching: true, query: query}}
      },
      changed: %{ @state_key => @test_socket.assigns[@state_key] }
    }
    assert Searchable.handle_event("search-#{@target}", %{"query" => query}, @test_socket) 
    == {:noreply, expected}
  end
end
