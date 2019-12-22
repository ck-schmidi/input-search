defmodule InputsearchWeb.Live.DemoLive do
  use Phoenix.LiveView

  alias InputsearchWeb.Live.DemoLive.AutocompleteComponent

  def mount(_session, socket) do
    socket =
      socket
      |> assign(:entries, test_data())
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

  def handle_info({:updated_selected_entry, selected_entry}, socket) do
    {:noreply, assign(socket, :selected_entry, selected_entry)}
  end

  defp test_data do
    [
      %{name: "Linz Parzhofstraße"},
      %{name: "Linz Hofgasse"},
      %{name: "Linz Graben"},
      %{name: "Wien Wurzbachgasse"},
      %{name: "Wien Prater"}
    ]
  end
end
