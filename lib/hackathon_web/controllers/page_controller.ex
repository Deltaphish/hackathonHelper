defmodule HackathonWeb.PageController do
  use HackathonWeb, :controller

  def home(conn, _params) do
    {:ok, current_date} = DateTime.now("Europe/Stockholm")
    {:ok, event_start} = DateTime.new(~D[2025-01-24], ~T[15:01:00.000], "Europe/Stockholm")

    if DateTime.compare(current_date, event_start) == :lt do
      display_string = Calendar.strftime(current_date, "%y-%m-%d %I:%M %p")
      render(conn, :home, current_date: display_string)
    else
      render(conn, :home, current_date: "Foobar")
    end
  end
end
