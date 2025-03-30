defmodule SkepticBotWeb.WebhookController do
  use SkepticBotWeb, :controller

  alias SkepticBot.WebhookHandler

  def replicate(conn, payload) do
    WebhookHandler.handle_webhook(payload)

    conn
    |> put_status(:ok)
    |> json(%{status: "ok"})
  end
end
