defmodule SkepticBotWeb.Plugs.BodyReader do
  @moduledoc """
  A plug that reads the raw body of a request and stores it in the connection assigns.
  This is useful for webhook verification where we need to access the raw body for signature verification.
  """

  @type conn :: Plug.Conn.t()
  @type opts :: Keyword.t()

  @doc """
  Reads the body from the connection and stores it in the assigns.
  Returns the body and the updated connection.
  """
  @spec read_body(conn(), opts()) :: {:ok, String.t(), conn()}
  def read_body(conn, opts) do
    {:ok, body, conn} = Plug.Conn.read_body(conn, opts)
    updated_conn = update_in(conn.assigns[:raw_body], &[body | &1 || []])
    {:ok, body, updated_conn}
  end
end
