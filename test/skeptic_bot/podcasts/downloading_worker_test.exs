defmodule SkepticBot.Podcasts.DownloadingWorkerTest do
  use SkepticBot.DataCase, async: true

  import Mox

  alias SkepticBot.DownloadingWorkerMock
  alias SkepticBot.Podcasts.DownloadingWorker

  @id "012eb1cb-5b41-405f-bcab-7a5236eee471"

  describe "process_with_flame/3" do
    test "enqueues a transcribing job if successful" do
      expect(DownloadingWorkerMock, :process_with_flame, fn _id, _url, _external_id ->
        {:ok, "random.mp3"}
      end)

      assert :ok =
               perform_job(DownloadingWorker, %{
                 id: @id,
                 external_id: "a909da70-13b7-4717-b1c0-c2d001521dc3"
               })

      assert_enqueued(
        worker: SkepticBot.Podcasts.TranscribingWorker,
        args: %{
          "id" => @id,
          "audio_url" => "random.mp3"
        }
      )
    end

    test "does not enqueue a transcribing job if unsuccessful" do
      expect(DownloadingWorkerMock, :process_with_flame, fn _id, _url, _external_id ->
        {:error, "Could not process the file"}
      end)

      assert {:error, "Could not process the file"} =
               perform_job(DownloadingWorker, %{
                 id: @id,
                 external_id: "a909da70-13b7-4717-b1c0-c2d001521dc3"
               })

      refute_enqueued(
        worker: SkepticBot.Podcasts.TranscribingWorker,
        args: %{
          "id" => @id,
          "audio_url" => "random.mp3"
        }
      )
    end
  end
end
