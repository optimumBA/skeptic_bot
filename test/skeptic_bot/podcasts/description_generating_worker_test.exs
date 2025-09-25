defmodule SkepticBot.Podcasts.DescriptionGeneratingWorkerTest do
  use SkepticBot.DataCase, async: true

  import ExUnit.CaptureLog
  import Mox
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DescriptionGeneratingWorker
  alias SkepticBot.Rag.EmbeddingsGeneratingWorker
  alias SkepticBot.Rag.MockEmbedder
  alias SkepticBot.Rag.MockGenerator

  @id "a909da70-13b7-4717-b1c0-c2d001521dc3"

  setup :verify_on_exit!

  defp create_episode(_attrs) do
    response =
      "Description:A Sam Tripoli episode description $&$ Summary:A Sam Tripoli episode summary"

    episode = episode_fixture()
    %{episode: episode, response: response}
  end

  describe "perform/1" do
    setup [:create_episode]

    test "generates a description and a summary for an episode and updates the embedding for existing episodes",
         %{
           response: response,
           episode: episode
         } do
      refute episode.embedding

      embedding = embedding_fixture()

      expect(MockGenerator, :predict, fn _messages, _output_mode ->
        {:ok, response}
      end)

      expect(MockEmbedder, :generate, fn _text ->
        {:ok, [embedding]}
      end)

      assert :ok =
               perform_job(DescriptionGeneratingWorker, %{
                 "id" => episode.id,
                 "episode_status" => "existing"
               })

      updated_episode = Podcasts.get_episode(episode.id)
      assert updated_episode.description == "A Sam Tripoli episode description"
      assert updated_episode.summary == "A Sam Tripoli episode summary"
      assert updated_episode.embedding
    end

    test "generates a description and a summary for an episode and enqueues an embedding_worker job for new episodes",
         %{
           response: response,
           episode: episode
         } do
      expect(MockGenerator, :predict, fn _messages, _output_mode ->
        {:ok, response}
      end)

      assert :ok =
               perform_job(DescriptionGeneratingWorker, %{
                 "id" => episode.id,
                 "episode_status" => "new"
               })

      updated_episode = Podcasts.get_episode(episode.id)
      assert updated_episode.description == "A Sam Tripoli episode description"
      assert updated_episode.summary == "A Sam Tripoli episode summary"

      assert_enqueued(
        worker: EmbeddingsGeneratingWorker,
        args: %{
          "id" => episode.id
        }
      )
    end

    test "logs an error when description generation fails" do
      log =
        capture_log(fn ->
          perform_job(DescriptionGeneratingWorker, %{
            "id" => @id,
            "episode_status" => "existing"
          })
        end)

      assert log =~ "Failed to process episode:"
    end

    @tag :capture_log
    test "returns an error when embedding generation fails", %{
      episode: episode
    } do
      expect(MockGenerator, :predict, fn _text, _output_mode ->
        {:error, "failed to generate a description"}
      end)

      assert {:error, "failed to generate a description"} =
               perform_job(DescriptionGeneratingWorker, %{
                 "id" => episode.id,
                 "episode_status" => "existing"
               })
    end
  end
end
