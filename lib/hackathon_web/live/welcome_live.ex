defmodule HackathonWeb.WelcomeLive do
  use HackathonWeb, :live_view

  @event_start DateTime.new!(~D[2024-02-24], ~T[15:00:00.000], "Europe/Stockholm")
  @event_end DateTime.new!(~D[2024-01-24], ~T[18:00:00.000], "Europe/Stockholm")


  def render(assigns) do
    ~H"""
      <time class="text-3xl">{@event_start}</time>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, current_date} = DateTime.now("Europe/Stockholm")


    socket = assign(socket, event_start: @event_start)

    if DateTime.compare(current_date, @event_start) == :lt do
      Process.send_after(self(),:tick, 100)
      display_string = Calendar.strftime(@event_start, "%y-%m-%d %I:%M %p")
      {:ok, assign(socket, event_start: display_string)}
    else
      {:ok, push_navigate(socket, to: "/dash")}
    end
  end

  def handle_info(:tick, socket) do
    {:ok, current_date} = DateTime.now("Europe/Stockholm")
    if DateTime.compare(current_date, @event_start) == :lt do
      Process.send_after(self(),:tick, 100)
      {:noreply, assign(socket, event_started?: false)}
    else
      {:noreply, push_navigate(socket, to: "/dash")}
    end
  end
end
