defmodule SkepticBot.Podcasts.DescriptionGeneratingWorkerTest do
  use SkepticBot.DataCase, async: true

  import ExUnit.CaptureLog
  import Mox
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DescriptionGeneratingWorker
  alias SkepticBot.Rag.MockEmbedder
  alias SkepticBot.Rag.MockGenerator

  @id "a909da70-13b7-4717-b1c0-c2d001521dc3"

  setup :verify_on_exit!

  defp create_episode(_attrs) do
    description = "A Sam Tripoli special"
    episode = episode_fixture()
    %{description: description, episode: episode}
  end

  describe "perform/1" do
    setup [:create_episode]

    test "generates a description for an episode", %{description: description, episode: episode} do
      embedding = embedding_fixture()

      expect(MockGenerator, :predict, fn _messages, _output_mode ->
        {:ok, description}
      end)

      expect(MockEmbedder, :generate, fn _text ->
        {:ok, [embedding]}
      end)

      assert :ok =
               perform_job(DescriptionGeneratingWorker, %{
                 "id" => episode.id
               })

      updated_episode = Podcasts.get_episode(episode.id)
      assert updated_episode.description == description
    end

    test "logs an error when description generation fails" do
      log =
        capture_log(fn ->
          perform_job(DescriptionGeneratingWorker, %{
            "id" => @id
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
                 "id" => episode.id
               })
    end
  end
end
