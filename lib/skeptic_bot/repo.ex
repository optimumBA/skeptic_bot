defmodule SkepticBot.Repo do
  use Ecto.Repo,
    otp_app: :skeptic_bot,
    adapter: Ecto.Adapters.Postgres
end
