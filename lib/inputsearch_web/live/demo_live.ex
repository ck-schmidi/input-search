defmodule InputsearchWeb.Live.DemoLive do
  use Phoenix.LiveView

  def mount(_session, socket) do
    socket =
      socket
      |> assign(:search_text, "")
      |> assign(:entries, [])
      |> assign(:selected_entry, nil)
      |> assign(:show_suggestions, false)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <h2>Autocomplete</h2>
    <p>Start typing:</p>

    <!--Make sure the form has the autocomplete function switched off:-->
    <form autocomplete="off" phx-change="change">
      <div class="autocomplete" style="width:300px;">
        <input id="myInput" type="text" name="search_text" placeholder="Country" value="<%= @search_text %>">
        <%= if @show_suggestions do %>
          <div id="autocomplete-list" class="autocomplete-items">
            <%= for entry <- @entries do %>
              <div phx-click="entry_selected" phx-value-id="<%= entry.id %>"><%= entry.name %></div>
            <% end %>
          </div>
        <% end %>
      </div>
      <input type="submit">
    </form>
    """
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
      |> assign(:search_text, search_text)
      |> assign(:entries, entries)
      |> set_show_suggestions
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
      |> assign(:show_suggestions, false)

    {:noreply, socket}
  end

  defp set_show_suggestions(socket) do
    assign(socket, :show_suggestions, socket.assigns.search_text != "")
  end
end
