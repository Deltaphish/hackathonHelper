defmodule Hackathon.MessageRepo do
  use GenServer
  alias Phoenix.PubSub

  # Client

  def start_link(state \\ []) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def send_message(message) do
    GenServer.cast(__MODULE__, {:send, message})
  end

  def revert() do
    GenServer.cast(__MODULE__, :pop)
  end

  def get_messages() do
    GenServer.call(__MODULE__, :get)
  end

  # Callbacks

  @impl true
  def init(_foo) do
    {:ok, []}
  end

  @impl true
  def handle_cast({:send, message}, state) do
    {:ok, current_date} = DateTime.now("Europe/Stockholm")
    new_state = ["[#{current_date.hour}:#{current_date.minute}] #{message}" | state]
    PubSub.broadcast(Hackathon.PubSub, "messages", {:message_update, new_state})
    {:noreply, new_state}
  end


  @impl true
  def handle_cast(:pop, state) do
    new_state = case state do
      [] -> []
      xs -> xs |> Enum.reverse() |> tl() |> Enum.reverse()
    end
    PubSub.broadcast(Hackathon.PubSub, "messages", {:message_update, new_state})
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end
end
