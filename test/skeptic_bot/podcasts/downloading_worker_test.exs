defmodule SkepticBot.Podcasts.DownloadingWorkerTest do
  use SkepticBot.DataCase, async: false

  import Mox
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Podcasts.DownloadingWorker
  alias SkepticBot.Podcasts.MockDownloader
  alias SkepticBot.Podcasts.MockTranscoder
  alias SkepticBot.Podcasts.TranscribingWorker
  alias SkepticBot.Storage.MockStorageProvider

  @id "012eb1cb-5b41-405f-bcab-7a5236eee471"
  @podcast_lookintoit "Look Into It"
  @podcast_tinfoilhat "Tin Foil Hat"
  @video_url "site/some_video.mp4"

  setup :set_mox_from_context
  setup :verify_on_exit!

  describe "perform/1" do
    test "enqueues a transcribing job if downloading Sam's podcasts is successful" do
      expect(MockDownloader, :download, fn _url, _video_path ->
        {:ok,
         "/var/folders/2w/T/012eb1cb-5b41-405f-bcab-7a5236eee471a909da70-13b7-4717-b1c0-c2d001521dc3.mp4"}
      end)

      expect(MockTranscoder, :transcode_video, fn _video_path, _audio_path ->
        :ok
      end)

      expect(MockStorageProvider, :upload_file, fn _audio_path, _content_type ->
        {:ok, "https://skeptic-bot-dev.fly.storage.tigris.dev/song.mp3"}
      end)

      assert :ok =
               perform_job(DownloadingWorker, %{
                 id: @id,
                 podcast: @podcast_tinfoilhat,
                 video_url: @video_url
               })

      assert_enqueued(
        worker: TranscribingWorker,
        args: %{
          "audio_url" => "https://skeptic-bot-dev.fly.storage.tigris.dev/song.mp3",
          "id" => @id
        }
      )
    end

    test "enqueues a transcribing job if downloading Eddie's podcasts is successful" do
      expect(MockDownloader, :download, fn _url, _video_path ->
        {:ok,
         "/var/folders/2w/T/012eb1cb-5b41-405f-bcab-7a5236eee471a909da70-13b7-4717-b1c0-c2d001521dc3.mp4"}
      end)

      expect(MockStorageProvider, :upload_file, fn _audio_path, _content_type ->
        {:ok, "https://skeptic-bot-dev.fly.storage.tigris.dev/song.mp3"}
      end)

      assert :ok =
               perform_job(DownloadingWorker, %{
                 id: @id,
                 podcast: @podcast_lookintoit,
                 video_url: @video_url
               })

      assert_enqueued(
        worker: TranscribingWorker,
        args: %{
          "audio_url" => "https://skeptic-bot-dev.fly.storage.tigris.dev/song.mp3",
          "id" => @id
        }
      )
    end

    @tag :capture_log
    test "does not enqueue a transcribing job if download process is unsuccessful" do
      expect(MockDownloader, :download, fn _url, _video_path ->
        {:error, "HTTP error: status 500"}
      end)

      assert {:error, "HTTP error: status 500"} =
               perform_job(DownloadingWorker, %{
                 id: @id,
                 podcast: @podcast_tinfoilhat,
                 video_url: @video_url
               })

      refute_enqueued(worker: TranscribingWorker)
    end

    @tag :capture_log
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
                 id: @id,
                 podcast: @podcast_tinfoilhat,
                 video_url: @video_url
               })

      refute_enqueued(worker: TranscribingWorker)
    end

    @tag :capture_log
    test "does not enqueue a transcribing job if uploading process is unsuccessful" do
      expect(MockDownloader, :download, fn _url, _video_path ->
        {:ok,
         "/var/folders/2w/T/012eb1cb-5b41-405f-bcab-7a5236eee471a909da70-13b7-4717-b1c0-c2d001521dc3.mp4"}
      end)

      expect(MockStorageProvider, :upload_file, fn _audio_path, _content_type ->
        {:error, "Failed to upload file. Status: 500"}
      end)

      assert {:error, "Failed to upload file. Status: 500"} =
               perform_job(DownloadingWorker, %{
                 id: @id,
                 podcast: @podcast_lookintoit,
                 video_url: @video_url
               })

      refute_enqueued(worker: TranscribingWorker)
    end
  end
end
