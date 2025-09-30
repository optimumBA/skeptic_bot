defmodule SkepticBot.Rag.EmbeddingsGeneratingWorkerTest do
  use SkepticBot.DataCase, async: true

  import ExUnit.CaptureLog
  import Mox
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Podcasts
  alias SkepticBot.Rag.EmbeddingsGeneratingWorker
  alias SkepticBot.Rag.MockEmbedder

  @id "a909da70-13b7-4717-b1c0-c2d001521dc3"

  setup :verify_on_exit!

  defp create_episode(_attrs) do
    embedding = embedding_fixture()
    episode = episode_fixture()
    _transcription = transcription_fixture(podcast_episode_id: episode.id)
    %{embedding: embedding, episode: episode}
  end

  describe "perform/1" do
    setup [:create_episode]

    test "generates an embedding for an episode", %{embedding: embedding, episode: episode} do
      refute episode.embedding

      expect(MockEmbedder, :generate, 2, fn _text ->
        {:ok, [embedding]}
      end)

      assert :ok =
               perform_job(EmbeddingsGeneratingWorker, %{
                 "id" => episode.id,
                 "status" => "new"
               })

      updated_episode = Podcasts.get_episode(episode.id)

      assert updated_episode.embedding
    end

    @tag :capture_log
    test "returns an error when an episode does not exist" do
      assert {:error, "Episode not found"} =
               perform_job(EmbeddingsGeneratingWorker, %{
                 "id" => @id,
                 "status" => "new"
               })
    end

    test "logs an error when embedding process fails" do
      log =
        capture_log(fn ->
          perform_job(EmbeddingsGeneratingWorker, %{
            "id" => @id,
            "status" => "new"
          })
        end)

      assert log =~ "Failed to generate embeddings for episode"
    end

    @tag :capture_log
    test "returns an error when embedding generation fails", %{
      episode: episode
    } do
      expect(MockEmbedder, :generate, fn _text ->
        {:error, "failed to connect"}
      end)

      assert {:error, "failed to connect"} =
               perform_job(EmbeddingsGeneratingWorker, %{
                 "id" => episode.id,
                 "status" => "new"
               })

      episode = Podcasts.get_episode(episode.id)

      refute episode.embedding
    end
  end
end
