defmodule InputsearchWeb.Live.DemoLive do
  use Phoenix.LiveView

  alias InputsearchWeb.Live.DemoLive.AutocompleteComponent

  def mount(_session, socket) do
    socket =
      socket
      |> assign(:entries, [])
      |> assign(:selected_entry, nil)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h2>Autocomplete</h2>
    <form autocomplete="off" phx-change="change" phx-submit="submit">
      <%= live_component @socket, AutocompleteComponent,
          id: "street",
          entries: @entries,
          selected_entry: @selected_entry
       %>
    </form>
    <div>
      <code>
        <%= @selected_entry |> inspect() %>
      </code>
    </div>
    """
  end

  def handle_info({:updated_selected_entry, "street", selected_entry}, socket) do
    {:noreply, assign(socket, :selected_entry, selected_entry)}
  end

  def handle_info({:updated_search_text, "street", search_text}, socket) do
    socket =
      socket
      |> assign(:selected_entry, nil)
      |> assign(:entries, test_data() |> filter_entries_by_query(search_text))

    {:noreply, socket}
  end

  def handle_event("submit", _, socket) do
    socket.assigns.selected_entry |> inspect() |> IO.puts()
    {:noreply, socket}
  end

  defp filter_entries_by_query(_, "") do
    []
  end

  defp filter_entries_by_query(data, query) do
    data
    |> Enum.filter(&(&1.name |> String.downcase() |> String.contains?(String.downcase(query))))
  end

  defp test_data do
    [
      %{name: "Linz Parzhofstraße"},
      %{name: "Linz Hofgasse"},
      %{name: "Linz Graben"},
      %{name: "Wien Wurzbachgasse"},
      %{name: "Wien Prater"},
      %{name: "Graz"},
      %{name: "Steyr"},
      %{name: "Wels"}
    ]
  end
end
