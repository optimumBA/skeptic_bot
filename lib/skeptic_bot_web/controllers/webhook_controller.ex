defmodule SkepticBotWeb.WebhookController do
  @moduledoc """
  Controller for handling webhook callbacks from external services.
  """

  use SkepticBotWeb, :controller

  alias SkepticBot.WebhookHandler

  @type conn :: Plug.Conn.t()
  @type params :: map()

  @spec replicate(conn(), params()) :: conn()
  def replicate(conn, params) do
    WebhookHandler.handle_webhook(params)

    conn
    |> put_status(:ok)
    |> json(%{status: "ok"})
  end
end
