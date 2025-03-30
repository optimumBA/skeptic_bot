defmodule SkepticBotWeb.Plugs.VerifyReplicateWebhook do
  import Phoenix.Controller
  import Plug.Conn
  require Logger

  @interesting_statuses ["succeeded", "failed", "canceled"]

  def init(opts), do: opts

  def call(conn, _opts) do
    with {:ok, raw_body} <- get_raw_body(conn),
         {:ok, status} <- get_prediction_status(raw_body),
         :ok <- verify_status(status),
         {:ok, signature} <- get_signature(conn),
         {:ok, webhook_id} <- get_webhook_id(conn),
         {:ok, timestamp} <- get_timestamp(conn),
         :ok <- verify_signature(raw_body, signature, webhook_id, timestamp) do
      conn
    else
      {:error, :skip_event} ->
        conn
        |> put_status(:ok)
        |> json(%{status: "ok"})
        |> halt()

      {:error, reason} ->
        Logger.error("Webhook verification failed: #{reason}")

        conn
        |> put_status(:unauthorized)
        |> json(%{error: reason})
        |> halt()
    end
  end

  defp get_prediction_status(raw_body) do
    case Jason.decode(raw_body) do
      {:ok, %{"status" => status}} -> {:ok, status}
      {:ok, _} -> {:error, "Missing status field"}
      {:error, _} -> {:error, "Invalid JSON payload"}
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
      [body | _] -> {:ok, body}
      _ -> {:error, "Missing request body"}
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
    webhook_secret = Application.fetch_env!(:skeptic_bot, :replicate)[:webhook_secret]

    secret =
      webhook_secret
      |> String.replace_prefix("whsec_", "")
      |> Base.decode64!()

    signed_content = "#{webhook_id}.#{timestamp}.#{body}"
    computed = :crypto.mac(:hmac, :sha256, secret, signed_content) |> Base.encode64()
    signatures = String.split(signature_header, " ")

    if Enum.any?(signatures, fn sig ->
         [_version, signature] = String.split(sig, ",")
         :crypto.hash_equals(Base.decode64!(signature), Base.decode64!(computed))
       end) do
      :ok
    else
      {:error, "Invalid signature"}
    end
  end
end
