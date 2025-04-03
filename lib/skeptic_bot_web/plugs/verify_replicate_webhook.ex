defmodule SkepticBotWeb.Plugs.VerifyReplicateWebhook do
  @moduledoc """
  Verifies the authenticity of incoming webhooks from Replicate.
  Validates the webhook signature, ID, and timestamp to ensure requests are genuine.
  """

  import Phoenix.Controller
  import Plug.Conn

  require Logger

  @type conn :: Plug.Conn.t()
  @type opts :: Plug.opts()

  @interesting_statuses ["succeeded", "failed", "canceled"]

  @spec init(opts()) :: opts()
  def init(opts), do: opts

  @spec call(conn(), opts()) :: conn()
  def call(conn, _opts) do
    case validate_webhook(conn) do
      :ok -> conn
      {:error, :skip_event} -> handle_skip_event(conn)
      {:error, reason} -> handle_error(conn, reason)
    end
  end

  defp validate_webhook(conn) do
    with {:ok, raw_body} <- get_raw_body(conn),
         {:ok, status} <- get_prediction_status(raw_body),
         :ok <- verify_status(status),
         {:ok, signature} <- get_signature(conn),
         {:ok, webhook_id} <- get_webhook_id(conn),
         {:ok, timestamp} <- get_timestamp(conn) do
      verify_signature(raw_body, signature, webhook_id, timestamp)
    end
  end

  defp handle_skip_event(conn) do
    conn
    |> put_status(:ok)
    |> json(%{status: "ok"})
    |> halt()
  end

  defp handle_error(conn, reason) do
    Logger.error("Webhook verification failed: #{reason}")

    conn
    |> put_status(:unauthorized)
    |> json(%{error: reason})
    |> halt()
  end

  defp get_prediction_status(raw_body) do
    case Jason.decode(raw_body) do
      {:ok, %{"status" => status}} -> {:ok, status}
      {:ok, _payload} -> {:error, "Missing status field"}
      {:error, _reason} -> {:error, "Invalid JSON payload"}
    end
  end

  defp verify_status(status) do
    if status in @interesting_statuses do
      :ok
    else
      {:error, :skip_event}
    end
  end

  defp get_raw_body(conn) do
    case conn.assigns[:raw_body] do
      [body | _rest] -> {:ok, body}
      _invalid -> {:error, "Missing request body"}
    end
  end

  defp get_signature(conn) do
    case get_req_header(conn, "webhook-signature") do
      [signature] -> {:ok, signature}
      [] -> {:error, "Missing signature"}
    end
  end

  defp get_webhook_id(conn) do
    case get_req_header(conn, "webhook-id") do
      [id] -> {:ok, id}
      [] -> {:error, "Missing webhook-id"}
    end
  end

  defp get_timestamp(conn) do
    case get_req_header(conn, "webhook-timestamp") do
      [timestamp] -> {:ok, timestamp}
      [] -> {:error, "Missing webhook-timestamp"}
    end
  end

  defp verify_signature(body, signature_header, webhook_id, timestamp) do
    secret =
      :skeptic_bot
      |> Application.fetch_env!(:replicate)
      |> Keyword.fetch!(:webhook_secret)
      |> String.replace_prefix("whsec_", "")
      |> Base.decode64!()

    signed_content = "#{webhook_id}.#{timestamp}.#{body}"
    computed_mac = :crypto.mac(:hmac, :sha256, secret, signed_content)

    valid_signature =
      signature_header
      |> String.split(" ")
      |> Enum.any?(fn signature ->
        decoded_signature =
          signature
          |> String.split(",")
          |> Enum.at(1)
          |> Base.decode64!()

        :crypto.hash_equals(decoded_signature, computed_mac)
      end)

    if valid_signature do
      :ok
    else
      {:error, "Invalid signature"}
    end
  end
end
