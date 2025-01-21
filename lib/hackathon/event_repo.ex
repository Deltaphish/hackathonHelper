defmodule Hackathon.EventRepo do
  use GenServer
  alias Phoenix.PubSub

  import Hackathon.Event
  # Client

  def start_link([]) do
    GenServer.start_link(__MODULE__, event(), name: __MODULE__)
  end

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def set_event_start(start_dt) do
    GenServer.cast(__MODULE__, {:set_start, start_dt})
  end

  def set_event_end(end_dt) do
    GenServer.cast(__MODULE__, {:set_end, end_dt})
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  # Callbacks

  @impl true
  def init(event) do
    {:ok, event}
  end

  @impl true
  def handle_cast({:set_start, new_start}, state) do
    new_state = event(state, start: new_start)
    PubSub.broadcast(Hackathon.PubSub, "time_update", {:time_update, new_state})
    {:noreply, new_state}
  end

  @impl true
  def handle_cast({:set_end, new_end}, state) do
    new_state = event(state, end: new_end)
    PubSub.broadcast(Hackathon.PubSub, "time_update", {:time_update, new_state})
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
