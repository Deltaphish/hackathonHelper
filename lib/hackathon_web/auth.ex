defmodule HackathonWeb.Auth do
  @behaviour Plug

  def init(_opts) do
    System.fetch_env!("AUTH_PASSWORD")
  end

  def call(conn, password) do
    Plug.BasicAuth.basic_auth(conn, username: "Coil8372", password: password)
  end

end
