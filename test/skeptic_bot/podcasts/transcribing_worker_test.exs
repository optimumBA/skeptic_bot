defmodule SkepticBot.Podcasts.TranscribingWorkerTest do
  use SkepticBot.DataCase, async: true

  import ExUnit.CaptureLog
  import Mox
  import SkepticBot.PodcastsFixtures
  import SkepticBot.ScrapingFixtures

  alias SkepticBot.Podcasts.MockTranscriber
  alias SkepticBot.Podcasts.TranscribingWorker
  alias SkepticBot.Rag.EmbeddingsGeneratingWorker
  alias SkepticBot.Storage.MockStorageProvider

  setup :verify_on_exit!

  defp create_chunks(_attrs) do
    chunks = chunks_fixture()
    episode = episode_fixture()
    %{chunks: chunks, episode: episode}
  end

  describe "perform/1" do
    setup [:create_chunks]

    test "enqueues a transcribing job if successful", %{
      chunks: chunks,
      episode: episode
    } do
      expect(MockTranscriber, :transcribe, fn _audio_url ->
        {:ok, chunks}
      end)

      expect(MockStorageProvider, :delete_file, fn _filename ->
        :ok
      end)

      assert :ok =
               perform_job(TranscribingWorker, %{
                 "audio_url" => "random.mp3",
                 "id" => episode.id
               })

      assert_enqueued(
        worker: EmbeddingsGeneratingWorker,
        args: %{
          "id" => episode.id
        }
      )
    end

    @tag :capture_log
    test "returns an error tuple if transcribing process fails", %{
      episode: episode
    } do
      expect(MockTranscriber, :transcribe, fn _audio_url ->
        {:error, "Failed to transcribe the episode"}
      end)

      assert {:error, "Failed to transcribe the episode"} =
               perform_job(TranscribingWorker, %{
                 "audio_url" => "random.mp3",
                 "id" => episode.id
               })

      refute_enqueued(
        worker: EmbeddingsGeneratingWorker,
        args: %{
          "id" => episode.id
        }
      )
    end

    test "logs an error message if it fails to delete a file from the storage provider", %{
      chunks: chunks,
      episode: episode
    } do
      expect(MockTranscriber, :transcribe, fn _audio_url ->
        {:ok, chunks}
      end)

      expect(MockStorageProvider, :delete_file, fn _filename ->
        {:error, "Storage provider is not available"}
      end)

      log =
        capture_log(fn ->
          perform_job(TranscribingWorker, %{
            "audio_url" => "random.mp3",
            "id" => episode.id
          })
        end)

      assert log =~ "Storage provider is not available"
    end
  end

  describe "enqueue/1" do
    setup [:create_chunks]

    test "with valid arguments enqueues a transcribing job", %{
      episode: episode
    } do
      TranscribingWorker.enqueue(%{"id" => episode.id, "audio_url" => "random.mp3"})

      assert_enqueued(
        worker: TranscribingWorker,
        args: %{
          "audio_url" => "random.mp3",
          "id" => episode.id
        }
      )
    end

    test "with invalid arguments does not enqueue a transcribing job", %{
      episode: episode
    } do
      TranscribingWorker.enqueue(%{"id" => episode.id, "audio_urle" => "random.mp3"})

      refute_enqueued(
        worker: TranscribingWorker,
        args: %{
          "audio_url" => "random.mp3",
          "id" => episode.id
        }
      )
    end
  end
end
