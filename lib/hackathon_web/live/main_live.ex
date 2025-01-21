defmodule HackathonWeb.MainLive do
  use HackathonWeb, :live_view
  alias Phoenix.PubSub

  import Hackathon.Event

  @impl true
  def mount(_params, _session, socket) do
    PubSub.subscribe(Hackathon.PubSub, "messages")
    PubSub.subscribe(Hackathon.PubSub, "time_update")

    messages = Hackathon.MessageRepo.get_messages()
    timeslot = Hackathon.EventRepo.get()


    {:ok, current_date} = DateTime.now("Europe/Stockholm")

    if DateTime.compare(current_date, event(timeslot, :start)) == :lt do
      {:ok, push_navigate(socket, to: "/")}
    else
      {_time_to_next_poll_ms, deadline_string} = time_to(current_date, event(timeslot, :end))
      Process.send_after(self(),:tick, 10)
      {:ok, socket |> assign(to_deadline: deadline_string)
                   |> assign(unread_messages: 0)
                   |> assign(messages: messages)
                   |> assign(timeslot: timeslot)
                   |> assign(active_tab: "deadline")}
    end
  end

  @impl true
  def handle_event("change_tab", %{"tab" => tab}, socket) do
    socket =
      if tab == "messages" do
        assign(socket, unread_messages: 0)
      else
        socket
      end
    {:noreply, assign(socket, active_tab: tab)}
  end

  @impl true
  def handle_info({:message_update, messages}, socket) do
    socket =
      if socket.assigns[:active_tab] != "messages" do
        update(socket, :unread_messages, &(&1 + 1))
      else
        socket
      end
    {:noreply, assign(socket, messages: messages)}
  end


  @impl true
  def handle_info({:time_update, time_slot}, socket) do
    {:ok, current_date} = DateTime.now("Europe/Stockholm")
    {_, deadline_string} = time_to(current_date, event(time_slot, :end))
    {:noreply, socket
      	        |> assign(timeslot: time_slot)
                |> assign(to_deadline: deadline_string)}
  end

  @impl true
  def handle_info(:tick, socket) do
    {:ok, current_date} = DateTime.now("Europe/Stockholm")
    time_slot = socket.assigns[:timeslot]
    {time_to_next_poll_ms, deadline_string} = time_to(current_date, event(time_slot, :end))
    if time_to_next_poll_ms == 0 do
      {:noreply, assign(socket, to_deadline: deadline_string)}
    else
      Process.send_after(self(),:tick, time_to_next_poll_ms)
      {:noreply, assign(socket, to_deadline: deadline_string)}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mx-4">
      <nav class="flex justify-around bg-fuchsia-900">
      <button
            phx-click="change_tab"
            phx-value-tab="rules"
            class={"px-4 py-2 border-b-2 text-sm font-medium #{if @active_tab == "rules", do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}"}
       >Rules</button>
       <button
            phx-click="change_tab"
            phx-value-tab="deadline"
            class={"px-4 py-2 border-b-2 text-sm font-medium #{if @active_tab == "deadline", do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}"}
       >Deadline</button>
       <button
            phx-click="change_tab"
            phx-value-tab="messages"
            class={"px-4 py-2 border-b-2 text-sm font-medium #{if @active_tab == "messages", do: "border-blue-500 text-blue-600", else: "border-transparent text-gray-500 hover:text-gray-700 hover:border-gray-300"}"}
       >Messages({@unread_messages})</button>
      </nav>
      <%= case @active_tab do %>
      <% "deadline" -> %>
        <p>{@to_deadline}</p>
      <% "rules" ->  %>
        <ol class="list-decimal">
          <li>Teams must consist of 2-5 members</li>
          <li>For a team to be eligble for prizes they must be ready to present a "pitch" before the deadline</li>
          <li>A "pitch" must consist of a short 1-2 minute presentation, and a demonstration of a <abbr title="Minimal Viable Product">MVP</abbr></li>
          <li>All work related to the "pitch" must be conducted in the Cygni office</li>
          <li>The pitch must be "safe for work". If you are unsure please check with a host</li>
          <li>The hosts reserve the right to interpret, apply, and modify these rules at whim</li>
        </ol>
      <% "messages" -> %>
        <p :for={message <- @messages}>{message}</p>
      <% end %>
    </div>
    """
  end

  defp time_to(from, to) do
    duration_s = DateTime.diff(to, from)
    cond do
       duration_s <= 0 ->
          {0, "Times out! Head to Stordalen"}
       duration_s <= 59 and duration_s > 0 ->
          {499, "#{duration_s} seconds until deadline!!!"}
        duration_s >= 60 ->
          {1000 + 1000 * (60 - from.second), "#{div(duration_s, 3600)} hour(s) #{rem(div(duration_s,60),60)} minute(s) until deadline!"}
    end
  end

end
