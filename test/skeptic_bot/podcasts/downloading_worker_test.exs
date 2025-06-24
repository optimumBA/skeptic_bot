defmodule SkepticBot.Podcasts.DownloadingWorkerTest do
  use SkepticBot.DataCase, async: false

  import Mox

  alias SkepticBot.Podcasts.DownloadingWorker
  alias SkepticBot.Podcasts.MockDownloader
  alias SkepticBot.Podcasts.MockTranscoder
  alias SkepticBot.Podcasts.TranscribingWorker
  alias SkepticBot.Storage.MockStorageProvider

  @external_id "a909da70-13b7-4717-b1c0-c2d001521dc3"
  @id "012eb1cb-5b41-405f-bcab-7a5236eee471"

  setup :set_mox_from_context
  setup :verify_on_exit!

  describe "process_with_flame/3" do
    test "enqueues a transcribing job if successful" do
      expect(MockDownloader, :download, fn _url, _video_path ->
        {:ok,
         "/var/folders/2w/T/012eb1cb-5b41-405f-bcab-7a5236eee471a909da70-13b7-4717-b1c0-c2d001521dc3.mp4"}
      end)

      expect(MockTranscoder, :transcode_video, fn _video_path, _audio_path ->
        :ok
      end)

      expect(MockStorageProvider, :upload_file, fn _audio_path ->
        {:ok, "https://skeptic-bot-dev.fly.storage.tigris.dev/song.mp3"}
      end)

      assert :ok =
               perform_job(DownloadingWorker, %{
                 external_id: @external_id,
                 id: @id
               })

      assert_enqueued(
        worker: TranscribingWorker,
        args: %{
          "audio_url" => "https://skeptic-bot-dev.fly.storage.tigris.dev/song.mp3",
          "id" => @id
        }
      )
    end

    test "does not enqueue a transcribing job if download process is unsuccessful" do
      expect(MockDownloader, :download, fn _url, _video_path ->
        {:error, "HTTP error: status 500"}
      end)

      assert {:error, "HTTP error: status 500"} =
               perform_job(DownloadingWorker, %{
                 external_id: @external_id,
                 id: @id
               })

      refute_enqueued(worker: TranscribingWorker)
    end

    test "does not enqueue a transcribing job if trancoding process is unsuccessful" do
      expect(MockDownloader, :download, fn _url, _video_path ->
        {:ok,
         "/var/folders/2w/T/012eb1cb-5b41-405f-bcab-7a5236eee471a909da70-13b7-4717-b1c0-c2d001521dc3.mp4"}
      end)

      expect(MockTranscoder, :transcode_video, fn _video_path, _audio_path ->
        {:error, "Transcoding failed with exit code: 1"}
      end)

      assert {:error, "Transcoding failed with exit code: 1"} =
               perform_job(DownloadingWorker, %{
                 external_id: @external_id,
                 id: @id
               })

      refute_enqueued(worker: TranscribingWorker)
    end

    test "does not enqueue a transcribing job if uploading process is unsuccessful" do
      expect(MockDownloader, :download, fn _url, _video_path ->
        {:ok,
         "/var/folders/2w/T/012eb1cb-5b41-405f-bcab-7a5236eee471a909da70-13b7-4717-b1c0-c2d001521dc3.mp4"}
      end)

      expect(MockTranscoder, :transcode_video, fn _video_path, _audio_path ->
        :ok
      end)

      expect(MockStorageProvider, :upload_file, fn _audio_path ->
        {:error, "Failed to upload file. Status: 500"}
      end)

      assert {:error, "Failed to upload file. Status: 500"} =
               perform_job(DownloadingWorker, %{
                 external_id: @external_id,
                 id: @id
               })

      refute_enqueued(worker: TranscribingWorker)
    end
  end
end
