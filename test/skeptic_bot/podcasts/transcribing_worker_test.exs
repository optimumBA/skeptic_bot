defmodule SkepticBot.Podcasts.TranscribingWorkerTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.TinfoilScraperFixtures
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Podcasts.TranscribingWorker
  alias SkepticBot.TigrisMock
  alias SkepticBot.TranscriptionMock

  defp create_chunks(_attrs) do
    chunks = chunks_fixture()
    episode = episode_fixture()

    %{episode: episode, chunks: chunks}
  end

  describe "transcribe_episode/2" do
    setup [:create_chunks]

    test "enqueues a transcribing job if successful", %{episode: episode, chunks: chunks} do
      expect(TranscriptionMock, :transcribe, fn _audio_url ->
        {:ok, chunks}
      end)

      expect(TigrisMock, :delete_file, fn _filename ->
        :ok
      end)

      assert :ok =
               perform_job(TranscribingWorker, %{
                 "id" => episode.id,
                 "audio_url" => "random.mp3"
               })

      assert_enqueued(
        worker: SkepticBot.Rag.EmbeddingsGeneratingWorker,
        args: %{
          "id" => episode.id
        }
      )
    end

    test "returns an error tuple if transcription fails", %{
      episode: episode
    } do
      expect(TranscriptionMock, :transcribe, fn _audio_url ->
        {:error, "Failed to transcribe the episode"}
      end)

      assert {:error, "Failed to transcribe the episode"} =
               perform_job(TranscribingWorker, %{
                 "id" => episode.id,
                 "audio_url" => "random.mp3"
               })

      refute_enqueued(
        worker: SkepticBot.Rag.EmbeddingsGeneratingWorker,
        args: %{
          "id" => episode.id
        }
      )
    end

    test "enqueus a transcription job", %{
      episode: episode
    } do
      TranscribingWorker.enqueue(%{"id" => episode.id, "audio_url" => "random.mp3"})

      assert_enqueued(
        worker: TranscribingWorker,
        args: %{
          "id" => episode.id,
          "audio_url" => "random.mp3"
        }
      )
    end
  end
end
