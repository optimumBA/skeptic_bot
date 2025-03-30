defmodule SkepticBot.WebhookHandler do
  use GenServer

  require Logger

  @registry_name :prediction_registry

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    {:ok, %{}}
  end

  def handle_webhook(payload) do
    GenServer.cast(__MODULE__, {:handle_webhook, payload})
  end

  @impl true
  def handle_cast({:handle_webhook, %{"id" => prediction_id} = payload}, state) do
    handle_prediction_result(payload, prediction_id)
    {:noreply, state}
  end

  def handle_cast({:handle_webhook, _payload}, state) do
    Logger.warning("Received webhook without prediction ID")
    {:noreply, state}
  end

  defp handle_prediction_result(%{"status" => "succeeded", "output" => output}, prediction_id) do
    case Registry.lookup(@registry_name, prediction_id) do
      [{pid, _}] ->
        send(pid, {:prediction_completed, prediction_id, output})
        unregister_prediction(prediction_id)

      [] ->
        Logger.warning("No process waiting for prediction #{prediction_id}")
    end
  end

  defp handle_prediction_result(%{"status" => "failed", "error" => error}, prediction_id) do
    Logger.error("Prediction #{prediction_id} failed: #{error}")
    notify_prediction_failed(prediction_id, error)
  end

  defp handle_prediction_result(%{"status" => "canceled"}, prediction_id) do
    Logger.info("Prediction #{prediction_id} was canceled")
    notify_prediction_failed(prediction_id, "Prediction was canceled")
  end

  defp handle_prediction_result(_payload, prediction_id) do
    Logger.warning("Received webhook with unknown status for prediction #{prediction_id}")
  end

  defp notify_prediction_failed(prediction_id, error) do
    case Registry.lookup(@registry_name, prediction_id) do
      [{pid, _}] ->
        send(pid, {:prediction_failed, prediction_id, error})
        unregister_prediction(prediction_id)

      [] ->
        Logger.warning("No process waiting for prediction #{prediction_id}")
    end
  end

  def register_for_prediction(prediction_id, pid) do
    Registry.register(@registry_name, prediction_id, pid)
  end

  def unregister_prediction(prediction_id) do
    Registry.unregister(@registry_name, prediction_id)
  end
end
