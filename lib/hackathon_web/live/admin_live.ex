defmodule HackathonWeb.AdminLive do
  use HackathonWeb, :live_view

  @event_start DateTime.new!(~D[2024-02-24], ~T[15:00:00.000], "Europe/Stockholm")
  @event_end DateTime.new!(~D[2024-01-24], ~T[18:00:00.000], "Europe/Stockholm")


  def render(assigns) do
    ~H"""
      <h1>Admin dashboard</h1>
      <h2>Messages</h2>
      <button type="button" phx-click="revert">Revert last message</button>
      <form phx-submit="send_message">
        <input type="text" name="content"/>
        <button type="submit" phx-disable-with="Sending...">Send</button>
      </form>
      <form phx-submit="update_time">
        <label>Starting time</label>
        <input type="datetime-local" name="start_date" />
        <button type="submit">Submit</button>
      </form>
      <form phx-submit="update_time">
        <label>Deadline time</label>
        <input type="datetime-local" name="end_date" />
        <button type="submit">Submit</button>
      </form>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("revert", _event, socket) do
    Hackathon.MessageRepo.revert()
    {:noreply, socket}
  end

  @impl true
  def handle_event("send_message", %{"content" => message_content}, socket) do
    Hackathon.MessageRepo.send_message(message_content)
    {:noreply, socket}
  end

  @impl true
  def handle_event("update_time", %{"start_date" => start_date}, socket) do
    {:ok, ndt} = NaiveDateTime.from_iso8601(start_date <> ":00")
    {:ok, dt} = DateTime.from_naive(ndt, "Europe/Stockholm")
    Hackathon.EventRepo.set_event_start(dt)
    {:noreply, socket}
  end

  @impl true
  def handle_event("update_time", %{"end_date" => end_date}, socket) do
    {:ok, ndt} = NaiveDateTime.from_iso8601(end_date <> ":00")
    {:ok, dt} = DateTime.from_naive(ndt, "Europe/Stockholm")
    Hackathon.EventRepo.set_event_end(dt)
    {:noreply, socket}
  end
end
