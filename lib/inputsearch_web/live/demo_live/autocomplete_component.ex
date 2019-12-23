defmodule InputsearchWeb.Live.DemoLive.AutocompleteComponent do
  use Phoenix.LiveComponent

  @spec render(any) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~L"""
    <div class="autocomplete">
      <input type="text" name="search_text" placeholder="Departure" value="<%= @search_text %>">
      <%= if !@selected_entry do %>
        <div id="autocomplete-list" class="autocomplete-items">
          <%= for entry <- @entries do %>
            <div phx-click="entry_selected" phx-value-uuid="<%= entry.uuid %>"><%= entry.name %></div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  def update(assigns, socket) do
    entries =
      assigns.entries
      |> add_uuids

    socket =
      socket
      |> assign(:entries, entries)
      |> assign(:selected_entry, assigns.selected_entry)
      |> assign(:search_text, search_text(assigns.selected_entry))

    {:ok, socket}
  end

  defp add_uuids(entries) do
    entries |> Enum.map(&Map.put_new(&1, :uuid, UUID.uuid4()))
  end

  defp remove_uuid(entry) do
    entry |> Map.drop([:uuid])
  end

  defp search_text(search_text) do
    if search_text do
      search_text.name
    else
      ""
    end
  end

  defp get_entry_by_uuid(data, uuid) do
    data |> Enum.filter(&(&1.uuid == uuid)) |> Enum.at(0)
  end

  def handle_event("change", %{"search_text" => search_text}, socket) do
    send(self(), {:updated_search_text, search_text})
    {:noreply, socket}
  end

  def handle_event("entry_selected", %{"uuid" => uuid}, socket) do
    entry = get_entry_by_uuid(socket.assigns.entries, uuid)

    socket =
      socket
      |> assign(:selected_entry, entry)
      |> assign(:search_text, entry.name)

    send(self(), {:updated_selected_entry, entry |> remove_uuid})
    {:noreply, socket}
  end
end
