defmodule SkepticBot.ReplicateClient do
  @moduledoc """
  Common functionality for Replicate API interactions.
  """

  use SkepticBotWeb, :verified_routes

  require Logger

  alias SkepticBot.WebhookHandler

  @callback get_type() :: String.t()
  @callback handle_output(any()) :: any()

  def start_prediction(module, model, input, timeout \\ :timer.minutes(5)) do
    replicate_config = Application.fetch_env!(:skeptic_bot, :replicate)
    api_token = Keyword.fetch!(replicate_config, :api_token)
    webhook_url = url(~p"/webhook/replicate")

    version =
      case String.split(model, ":") do
        [_, version] -> version
        [model_id] -> model_id
      end

    case Req.post!("https://api.replicate.com/v1/predictions",
           json: %{
             version: version,
             input: input,
             webhook: webhook_url
           },
           headers: [{"Authorization", "Token #{api_token}"}]
         ) do
      %Req.Response{status: 201, body: %{"id" => prediction_id}} ->
        wait_for_webhook(module, prediction_id, timeout)

      %Req.Response{status: status, body: body} ->
        Logger.error(
          "Failed to start #{module.get_type()}. Status: #{status}, Response: #{inspect(body)}"
        )

        {:error, "Failed to start #{module.get_type()}"}
    end
  end

  defp wait_for_webhook(module, prediction_id, timeout) do
    WebhookHandler.register_for_prediction(prediction_id, self())

    receive do
      {:prediction_completed, ^prediction_id, output} ->
        WebhookHandler.unregister_prediction(prediction_id)
        {:ok, module.handle_output(output)}

      {:prediction_failed, ^prediction_id, error} ->
        Logger.error("#{module.get_type()} failed: #{error}")
        WebhookHandler.unregister_prediction(prediction_id)
        {:error, "#{module.get_type()} failed: #{error}"}
    after
      timeout ->
        WebhookHandler.unregister_prediction(prediction_id)
        {:error, "#{module.get_type()} timed out"}
    end
  end

  def handle_webhook(_module, %{
        "id" => prediction_id,
        "status" => "succeeded",
        "output" => output
      }) do
    case Registry.lookup(:prediction_registry, prediction_id) do
      [{pid, _}] ->
        send(pid, {:prediction_completed, prediction_id, output})

      [] ->
        Logger.warning("No process waiting for prediction #{prediction_id}")
    end

    :ok
  end

  def handle_webhook(_module, %{"id" => prediction_id, "status" => "failed", "error" => error}) do
    case Registry.lookup(:prediction_registry, prediction_id) do
      [{pid, _}] ->
        send(pid, {:prediction_failed, prediction_id, error})

      [] ->
        Logger.warning("No process waiting for prediction #{prediction_id}")
    end

    :ok
  end

  def handle_webhook(_module, _payload), do: :ok
end
