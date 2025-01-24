defmodule HackathonWeb.WelcomeLive do
  use HackathonWeb, :live_view
  alias Phoenix.PubSub


  import Hackathon.Event

  def render(assigns) do
    ~H"""
      <div class="flex h-full justify-center flex-col ">
        <time class="text-3xl">{@event_start}</time>
      </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, current_date} = DateTime.now("Europe/Stockholm")
    PubSub.subscribe(Hackathon.PubSub, "time_update")
    timeslot = Hackathon.EventRepo.get()


    socket = assign(socket, timeslot: timeslot)

    if DateTime.compare(current_date, event(timeslot, :start)) == :lt do
      Process.send_after(self(),:tick, 100)
      display_string = Calendar.strftime(event(timeslot, :start), "%y-%m-%d %I:%M %p")
      {:ok, assign(socket, event_start: display_string)}
    else
      {:ok, push_navigate(socket, to: "/dash")}
    end
  end

  def handle_info(:tick, socket) do
    {:ok, current_date} = DateTime.now("Europe/Stockholm")
    if DateTime.compare(current_date, event(socket.assigns[:timeslot], :start)) == :lt do
      Process.send_after(self(),:tick, 100)
      {:noreply, assign(socket, event_started?: false)}
    else
      {:noreply, push_navigate(socket, to: "/dash")}
    end
  end


  @impl true
  def handle_info({:time_update, new_state}, socket) do
    {:noreply, socket
                |> assign(timeslot: new_state)
                |> assign(event_start: Calendar.strftime(event(new_state, :start), "%y-%m-%d %I:%M %p"))}
  end
end
