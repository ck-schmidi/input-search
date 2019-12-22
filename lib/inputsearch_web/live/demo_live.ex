defmodule InputsearchWeb.Live.DemoLive do
  use Phoenix.LiveView

  def mount(_session, socket) do
    socket =
      socket
      |> assign(:search_text, "")
      |> assign(:entries, [])
      |> assign(:selected_entry, nil)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h2>Autocomplete</h2>
    <p>Start typing:</p>

    <!--Make sure the form has the autocomplete function switched off:-->
    <form autocomplete="off" phx-change="change" phx-submit="submit">
      <div class="autocomplete" style="width:300px;">
        <input type="text" name="search_text" placeholder="Departure" value="<%= @search_text %>">
        <%= if !@selected_entry do %>
          <div id="autocomplete-list" class="autocomplete-items">
            <%= for entry <- @entries do %>
              <div phx-click="entry_selected" phx-value-id="<%= entry.id %>"><%= entry.name %></div>
            <% end %>
          </div>
        <% end %>
      </div>
      <%= if @selected_entry do %>
        <input type="hidden" name="selected_id" value="<%= @selected_entry.id %>">
      <% end %>
      <input type="submit">
    </form>

    <code>
      <%= @selected_entry |> inspect() %>
    </code
    """
  end

  defp filter_entries_by_query(_, "") do
    []
  end

  defp filter_entries_by_query(data, query) do
    data
    |> Enum.filter(&(&1.name |> String.downcase() |> String.contains?(String.downcase(query))))
  end

  defp get_entry_by_id(data, idx) do
    data |> Enum.filter(&(&1.id == idx)) |> Enum.at(0)
  end

  defp test_data do
    [
      %{id: 0, name: "Linz Parzhofstraße"},
      %{id: 1, name: "Linz Hofgasse"},
      %{id: 2, name: "Linz Graben"},
      %{id: 4, name: "Wien Wurzbachgasse"},
      %{id: 5, name: "Wien Prater"}
    ]
  end

  def handle_event("change", %{"search_text" => search_text}, socket) do
    entries = test_data() |> filter_entries_by_query(search_text)

    socket =
      socket
      |> assign(:selected_entry, nil)
      |> assign(:search_text, search_text)
      |> assign(:entries, entries)
      |> IO.inspect()

    {:noreply, socket}
  end

  def handle_event("entry_selected", %{"id" => id}, socket) do
    idx = String.to_integer(id)
    entry = get_entry_by_id(socket.assigns.entries, idx)

    socket =
      socket
      |> assign(:selected_entry, entry)
      |> assign(:search_text, entry.name)

    {:noreply, socket}
  end

  def handle_event("submit", %{"selected_id" => selected_id}, socket) do
    idx = String.to_integer(selected_id)

    get_entry_by_id(socket.assigns.entries, idx)
    |> IO.inspect()

    {:noreply, socket}
  end

  def handle_event("submit", _, socket) do
    IO.puts("no entry selected")
    {:noreply, socket}
  end
end
