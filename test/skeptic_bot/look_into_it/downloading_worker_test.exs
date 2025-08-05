defmodule SkepticBot.LookIntoIt.DownloadingWorkerTest do
  use SkepticBot.DataCase, async: false

  import Mox

  alias SkepticBot.LookIntoIt.DownloadingWorker
  alias SkepticBot.Podcasts.MockDownloader
  alias SkepticBot.Podcasts.TranscribingWorker
  alias SkepticBot.Storage.MockStorageProvider

  @video_url "https://rkfn-media.global.ssl.fastly.net/QjbX4kN101bkX5wpKISHVxA3HaSR74n5D4gXCKId7JBM/v.mp4"
  @id "022eb1cb-5b41-405f-bcab-7a5236eee471"

  setup :set_mox_from_context
  setup :verify_on_exit!

  describe "perform/1" do
    test "enqueues a transcribing job if successful" do
      expect(MockDownloader, :download, fn _url, _video_path ->
        {:ok, "/var/folders/2w/T/022eb1cb-5b41-405f-bcab-7a5236eee471.mp4"}
      end)

      expect(MockStorageProvider, :upload_file, fn _audio_path ->
        {:ok, "https://skeptic-bot-dev.fly.storage.tigris.dev/music.mp3"}
      end)

      assert :ok =
               perform_job(DownloadingWorker, %{
                 id: @id,
                 video_url: @video_url
               })

      assert_enqueued(
        worker: TranscribingWorker,
        args: %{
          "audio_url" => "https://skeptic-bot-dev.fly.storage.tigris.dev/music.mp3",
          "id" => @id
        }
      )
    end

    @tag :capture_log
    test "does not enqueue a transcribing job if download process is unsuccessful" do
      expect(MockDownloader, :download, fn _url, _video_path ->
        {:error, "Download error: Connection Lost"}
      end)

      assert {:error, "Download error: Connection Lost"} =
               perform_job(DownloadingWorker, %{
                 id: @id,
                 video_url: @video_url
               })

      refute_enqueued(worker: TranscribingWorker)
    end

    @tag :capture_log
    test "does not enqueue a transcribing job if uploading process is unsuccessful" do
      expect(MockDownloader, :download, fn _url, _video_path ->
        {:ok, "/var/folders/2w/T/022eb1cb-5b41-405f-bcab-7a5236eee471.mp4"}
      end)

      expect(MockStorageProvider, :upload_file, fn _audio_path ->
        {:error, "Failed to upload file. Status: 500"}
      end)

      assert {:error, "Failed to upload file. Status: 500"} =
               perform_job(DownloadingWorker, %{
                 id: @id,
                 video_url: @video_url
               })

      refute_enqueued(worker: TranscribingWorker)
    end
  end
end
