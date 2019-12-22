defmodule InputsearchWeb.Live.DemoLive.AutocompleteComponent do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~L"""
    <div class="autocomplete">
      <input type="text" name="search_text" placeholder="Departure" value="<%= @search_text %>">
      <%= if !@selected_entry do %>
        <div id="autocomplete-list" class="autocomplete-items">
          <%= for entry <- @filtered_entries do %>
            <div phx-click="entry_selected" phx-value-id="<%= entry.id %>"><%= entry.name %></div>
          <% end %>
        </div>
      <% end %>
    </div>
    <%= if @selected_entry do %>
      <input type="hidden" name="selected_id" value="<%= @selected_entry.id %>">
    <% end %>
    """
  end

  def update(assigns, socket) do
    socket =
      socket
      |> assign(:entries, assigns.entries)
      |> assign(:selected_entry, assigns.selected_entry)
      |> assign(:filtered_entries, [])
      |> assign(:search_text, search_text(assigns.selected_entry))

    {:ok, socket}
  end

  defp search_text(search_text) do
    if search_text do
      search_text.name
    else
      ""
    end
  end

  defp get_entry_by_id(data, idx) do
    data |> Enum.filter(&(&1.id == idx)) |> Enum.at(0)
  end

  def handle_event("change", %{"search_text" => search_text}, socket) do
    entries = socket.assigns.entries |> filter_entries_by_query(search_text)

    socket =
      socket
      |> assign(:selected_entry, nil)
      |> assign(:search_text, search_text)
      |> assign(:filtered_entries, entries)

    send(self(), {:updated_selected_entry, nil})

    {:noreply, socket}
  end

  def handle_event("entry_selected", %{"id" => id}, socket) do
    idx = String.to_integer(id)
    entry = get_entry_by_id(socket.assigns.entries, idx)

    socket =
      socket
      |> assign(:selected_entry, entry)
      |> assign(:search_text, entry.name)

    send(self(), {:updated_selected_entry, entry})

    {:noreply, socket}
  end

  defp filter_entries_by_query(_, "") do
    []
  end

  defp filter_entries_by_query(data, query) do
    data
    |> Enum.filter(&(&1.name |> String.downcase() |> String.contains?(String.downcase(query))))
  end
end
