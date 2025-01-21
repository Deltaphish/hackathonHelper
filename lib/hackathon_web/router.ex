defmodule HackathonWeb.Router do
  use HackathonWeb, :router

  import Phoenix.LiveDashboard.Router


  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {HackathonWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authenticated do
    plug HackathonWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", HackathonWeb do
    pipe_through :browser
    live "/", WelcomeLive
    live "/dash", MainLive

  end

      scope "/admin" do
      pipe_through [:browser, :authenticated]

      live "/", HackathonWeb.AdminLive

      live_dashboard "/dashboard", metrics: HackathonWeb.Telemetry
    end
end
