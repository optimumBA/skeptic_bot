defmodule SkepticBot.WebhookHandlerTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureLog

  alias SkepticBot.WebhookHandler

  @canceled_prediction_payload %{
    "id" => "canceled-id",
    "status" => "canceled"
  }
  @failed_prediction_payload %{
    "id" => "failed-id",
    "status" => "failed",
    "error" => "HTTP 500 error"
  }
  @successful_prediction_payload %{
    "id" => "success-id",
    "status" => "succeeded",
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
      assert [] = Registry.lookup(SkepticBot.PredictionRegistry, "some-id")
    end
  end

  describe "handle_webhook/1" do
    @tag :capture_log
    test "notifies a process if its prediction failed" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("failed-id", self())
      WebhookHandler.handle_webhook(@failed_prediction_payload)
      assert_receive {:prediction_failed, "failed-id", "HTTP 500 error"}
    end

    @tag :capture_log
    test "does not notify a process of its prediction failure if it was unregistered" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("failed-id", self())
      WebhookHandler.handle_webhook(@failed_prediction_payload)
      assert :ok = WebhookHandler.unregister_prediction("failed-id")
      refute_receive {:prediction_failed, "failed-id", "HTTP 500 error"}
    end

    test "notifies a process if its prediction succeeded" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("success-id", self())
      WebhookHandler.handle_webhook(@successful_prediction_payload)
      assert_receive {:prediction_completed, "success-id", "good output"}
    end

    @tag :capture_log
    test "does not notify a process of its prediction success if it was unregistered" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("success-id", self())
      WebhookHandler.handle_webhook(@successful_prediction_payload)
      assert :ok = WebhookHandler.unregister_prediction("success-id")
      refute_receive {:prediction_completed, "success-id", "good output"}
    end

    test "notifies a process if its prediction was canceled" do
      assert {:ok, _owner_pid} = WebhookHandler.register_for_prediction("canceled-id", self())
      WebhookHandler.handle_webhook(@canceled_prediction_payload)
      assert_receive {:prediction_failed, "canceled-id", "Prediction was canceled"}
    end

    test "logs a warning message if the payload does not have a prediction_id" do
      log =
        capture_log([level: :warning], fn ->
          WebhookHandler.handle_webhook(%{"status" => "completed", "output" => "good output"})
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
        end)

      assert log =~ "Received webhook with unknown status for prediction some-id"
    end
  end
end
