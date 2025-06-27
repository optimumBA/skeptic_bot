defmodule SkepticBot.RagTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Rag

  setup :verify_on_exit!

  defp create_episodes(_attrs) do
    embedding = embedding_fixture()
    episode = episode_fixture(embedding: embedding)
    response = "Just a simple response from a large language model"
    _transcription = transcription_fixture(%{podcast_episode_id: episode.id})
    %{embedding: embedding, episode: episode, response: response}
  end

  describe "generate/1" do
    setup [:create_episodes]

    test "with valid query returns episodes and description", %{
      embedding: embedding,
      episode: episode,
      response: response
    } do
      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:ok, [embedding]}
      end)

      expect(Rag.MockGenerator, :predict, fn _messages ->
        {:ok, response}
      end)

      {:ok, {description, context}} = Rag.generate("Who Killed Two Pac Shakur")

      assert description == response

      assert Enum.any?(context, fn context_episode -> context_episode.id == episode.id end)
    end

    test "returns an error tuple if generation process was unsuccessful" do
      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:error, "Generation process was unsuccessful"}
      end)

      assert {:error, "Generation process was unsuccessful"} =
               Rag.generate("Who Killed Two Pac Shakur")
    end

    test "returns an error tuple if prediction process was unsuccessful", %{
      embedding: embedding
    } do
      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:ok, [embedding]}
      end)

      expect(Rag.MockGenerator, :predict, fn _messages ->
        {:error, "Prediction process was unsuccessful"}
      end)

      assert {:error, "Prediction process was unsuccessful"} =
               Rag.generate("Who Killed Two Pac Shakur")
    end
  end
end
