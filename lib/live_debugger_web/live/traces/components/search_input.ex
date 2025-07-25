defmodule LiveDebuggerWeb.Live.Traces.Components.SearchInput do
  @moduledoc """
  A search input component for filtering traces in global callback traces view. 
  """

  use LiveDebuggerWeb, :hook_component

  alias LiveDebuggerWeb.Live.Traces.Hooks

  @doc """
  Initializes the component by checking the assigns and attaching the hook to the socket.
  The hook is used to handle the `search` event.
  """
  @spec init(Phoenix.LiveView.Socket.t()) :: Phoenix.LiveView.Socket.t()
  def init(socket) do
    socket
    |> check_hook!(:existing_traces)
    |> check_assigns!(:trace_search_query)
    |> attach_hook(:search_input, :handle_event, &handle_event/3)
    |> register_hook(:search_input)
  end

  @doc """
  Renders the trace search input.
  It produces the `search` event that can be handled by the hook provided in the `init/1` function.
  """
  attr(:placeholder, :string, default: "Search...")
  attr(:disabled?, :boolean, default: false)
  attr(:trace_search_query, :string, default: "", doc: "The current search query for traces")

  @spec search_input(map()) :: Phoenix.LiveView.Rendered.t()
  def search_input(assigns) do
    ~H"""
    <div class={[
      "flex shrink items-center rounded-[7px] outline outline-1 -outline-offset-1",
      "has-[input:focus-within]:outline-2 has-[input:focus-within]:-outline-offset-2",
      "outline-default-border has-[input:focus-within]:outline-ui-accent"
    ]}>
      <form phx-change="search" phx-submit="submit" class="flex items-center w-full h-full">
        <.icon
          name="icon-search"
          class={[
            "h-4 w-4 ml-3",
            (@disabled? && "text-gray-400") || "text-primary-icon"
          ]}
        />
        <input
          disabled={@disabled?}
          id="trace-search-input"
          placeholder={@placeholder}
          value={@trace_search_query}
          type="text"
          name="search_query"
          class="block remove-arrow w-16 sm:w-64  min-w-32 bg-surface-0-bg border-none py-2.5 pl-2 pr-3 text-xs text-primary-text placeholder:text-ui-muted focus:ring-0 disabled:!text-gray-500 disabled:placeholder-grey-300
          "
        />
      </form>
    </div>
    """
  end

  defp handle_event("search", params, socket) do
    socket
    |> assign(trace_search_query: params["search_query"])
    |> Hooks.ExistingTraces.assign_async_existing_traces()
    |> push_event("collapse-all-traces", %{})
    |> halt()
  end

  defp handle_event("submit", _params, socket), do: socket |> halt()
  defp handle_event(_, _, socket), do: {:cont, socket}
end
