defmodule SkepticBot.ReplicateClient do
  @moduledoc """
  Common functionality for Replicate API interactions.
  """

  use SkepticBotWeb, :verified_routes

  alias SkepticBot.WebhookHandler

  require Logger

  @callback get_type() :: String.t()
  @callback handle_output(any()) :: any()

  @spec start_prediction(module(), atom(), String.t(), map(), timeout()) ::
          {:ok, any()} | {:error, String.t()}
  def start_prediction(module, process_type, model, input, timeout \\ :timer.minutes(5)) do
    replicate_config = Application.fetch_env!(:skeptic_bot, :replicate)
    api_token = Keyword.fetch!(replicate_config, :api_token)
    webhook_url = url(~p"/webhook/replicate")

    version =
      case String.split(model, ":") do
        [_model_id, version] -> version
        [model_id] -> model_id
      end

    case Req.post!("https://api.replicate.com/v1/predictions",
           json: %{
             version: version,
             input: input,
             webhook: webhook_url,
             webhook_events_filter: ["completed", "output"]
           },
           headers: [{"Authorization", "Token #{api_token}"}]
         ) do
      %Req.Response{status: 201, body: %{"id" => prediction_id}} ->
        wait_for_webhook(module, prediction_id, timeout, process_type)

      %Req.Response{status: status, body: body} ->
        Logger.error(
          "Failed to start #{module.get_type()}. Status: #{status}, Response: #{inspect(body)}"
        )

        {:error, "Failed to start #{module.get_type()}"}
    end
  end

  defp wait_for_webhook(module, prediction_id, timeout, :embedding) do
    WebhookHandler.register_for_prediction(prediction_id, self())

    receive do
      {:prediction_completed, ^prediction_id, output} ->
        {:ok, module.handle_output(output)}

      {:prediction_failed, ^prediction_id, error} ->
        Logger.error("#{module.get_type()} failed: #{error}")
        {:error, "#{module.get_type()} failed: #{error}"}
    after
      timeout ->
        WebhookHandler.unregister_prediction(prediction_id)
        {:error, "#{module.get_type()} timed out"}
    end
  end

  defp wait_for_webhook(module, prediction_id, timeout, :prediction) do
    WebhookHandler.register_for_prediction(prediction_id, self())

    receive do
      {:prediction_underway, ^prediction_id, output} ->
        {:ok, module.handle_output(output)}

      {:prediction_failed, ^prediction_id, error} ->
        Logger.error("#{module.get_type()} failed: #{error}")
        {:error, "#{module.get_type()} failed: #{error}"}
    after
      timeout ->
        WebhookHandler.unregister_prediction(prediction_id)
        {:error, "#{module.get_type()} timed out"}
    end
  end
end
