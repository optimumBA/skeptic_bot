defmodule SkepticBot.WebhookHandlerTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias SkepticBot.PredictionRegistry
  alias SkepticBot.WebhookHandler

  @canceled_prediction_payload %{
    "id" => "some-id",
    "status" => "canceled"
  }
  @failed_prediction_payload %{
    "id" => "some-id",
    "status" => "failed",
    "error" => "HTTP 500 error"
  }
  @successful_prediction_payload %{
    "id" => "some-id",
    "status" => "succeeded",
    "output" => "good output"
  }
  @processing_prediction_payload %{
    "id" => "some-id",
    "status" => "processing",
    "output" => "good output"
  }

  describe "register_for_prediction/2" do
    test "registers a pid for prediction" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("some-id", self())
    end

    test "does not register a pid for duplicate keys" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("some-id", self())

      assert {:error, {:already_registered, _pid}} =
               WebhookHandler.register_for_prediction("some-id", self())
    end
  end

  describe "unregister_prediction/1" do
    test "unregisters a pid using its unique key" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("some-id", self())
      assert :ok = WebhookHandler.unregister_prediction("some-id")
      assert [] = Registry.lookup(PredictionRegistry, "some-id")
    end
  end

  describe "handle_webhook/1" do
    @tag :capture_log
    test "notifies a process if its prediction failed" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("some-id", self())
      WebhookHandler.handle_webhook(@failed_prediction_payload)
      assert_receive {:prediction_failed, "some-id", "HTTP 500 error"}
    end

    @tag :capture_log
    test "does not notify a process of its prediction failure if it was unregistered" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("some-id", self())
      WebhookHandler.handle_webhook(@failed_prediction_payload)
      assert :ok = WebhookHandler.unregister_prediction("some-id")
      refute_receive {:prediction_failed, "some-id", "HTTP 500 error"}
    end

    test "notifies a process if its prediction succeeded" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("some-id", self())
      WebhookHandler.handle_webhook(@successful_prediction_payload)
      Process.sleep(1000)
      assert_receive {:prediction_completed, "some-id", "good output"}
    end

    @tag :capture_log
    test "does not notify a process of its prediction success if it was unregistered" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("some-id", self())
      WebhookHandler.handle_webhook(@successful_prediction_payload)
      assert :ok = WebhookHandler.unregister_prediction("some-id")
      refute_receive {:prediction_completed, "some-id", "good output"}
    end

    test "notifies a process if its prediction is processing" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("some-id", self())
      WebhookHandler.handle_webhook(@processing_prediction_payload)
      assert_receive {:prediction_underway, "some-id", "good output"}
    end

    @tag :capture_log
    test "does not notify a process of its prediction is processing if it was unregistered" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("some-id", self())
      WebhookHandler.handle_webhook(@processing_prediction_payload)
      assert :ok = WebhookHandler.unregister_prediction("some-id")
      refute_receive {:prediction_underway, "some-id", "good output"}
    end

    test "notifies a process if its prediction was canceled" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("some-id", self())
      WebhookHandler.handle_webhook(@canceled_prediction_payload)
      assert_receive {:prediction_failed, "some-id", "Prediction was canceled"}
    end

    test "logs a warning message if the payload does not have a prediction_id" do
      log =
        capture_log([level: :warning], fn ->
          WebhookHandler.handle_webhook(%{"status" => "completed", "output" => "good output"})

          Process.sleep(10)
        end)

      assert log =~ "Received webhook without prediction ID"
    end

    test "logs a warning message if the payload has an unknown status" do
      log =
        capture_log([level: :warning], fn ->
          WebhookHandler.handle_webhook(%{
            "id" => "some-id",
            "status" => "unknown"
          })

          Process.sleep(10)
        end)

      assert log =~ "Received webhook with unknown status for prediction some-id"
    end
  end
end
