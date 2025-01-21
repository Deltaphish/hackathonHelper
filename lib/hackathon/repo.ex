defmodule Hackathon.Repo do
  use Ecto.Repo,
    otp_app: :hackathon,
    adapter: Ecto.Adapters.SQLite3
end
