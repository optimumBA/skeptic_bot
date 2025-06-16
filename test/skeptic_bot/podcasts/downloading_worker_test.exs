defmodule SkepticBot.Podcasts.DownloadingWorkerTest do
  use SkepticBot.DataCase, async: true

  import ExUnit.CaptureLog
  import Mox

  alias SkepticBot.MockDownloader
  alias SkepticBot.Podcasts.DownloadingWorker
  alias SkepticBot.Podcasts.TranscribingWorker

  @id "012eb1cb-5b41-405f-bcab-7a5236eee471"

  setup :verify_on_exit!

  describe "process_with_flame/3" do
    test "enqueues a transcribing job if successful" do
      expect(MockDownloader, :process_with_flame, fn _id, _url, _external_id ->
        {:ok, "song.mp3"}
      end)

      assert :ok =
               perform_job(DownloadingWorker, %{
                 id: @id,
                 external_id: "a909da70-13b7-4717-b1c0-c2d001521dc3"
               })

      assert_enqueued(
        worker: TranscribingWorker,
        args: %{
          "id" => @id,
          "audio_url" => "song.mp3"
        }
      )
    end

    test "does not enqueue a transcribing job if unsuccessful" do
      expect(MockDownloader, :process_with_flame, fn _id, _url, _external_id ->
        {:error, "Could not process the file"}
      end)

      assert {:error, "Could not process the file"} =
               perform_job(DownloadingWorker, %{
                 id: @id,
                 external_id: "a909da70-13b7-4717-b1c0-c2d001521dc3"
               })

      refute_enqueued(
        worker: TranscribingWorker,
        args: %{
          "id" => @id,
          "audio_url" => "random.mp3"
        }
      )
    end

    test "logs an error message if unsuccessful" do
      expect(MockDownloader, :process_with_flame, fn _id, _url, _external_id ->
        {:error, "Could not process the file"}
      end)

      log =
        capture_log(fn ->
          perform_job(DownloadingWorker, %{
            id: @id,
            external_id: "a909da70-13b7-4717-b1c0-c2d001521dc3"
          })
        end)

      assert log =~ "Could not process the file"
    end
  end
end
