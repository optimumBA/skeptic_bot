defmodule SkepticBot.RagTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.EmbeddingMock
  alias SkepticBot.PredictionMock
  alias SkepticBot.Rag

  defp create_episodes(_attrs) do
    episode = episode_fixture()
    embedding = embedding_fixture()
    response = "Just a simple response from a large language model"
    %{episode: episode, embedding: embedding, response: response}
  end

  describe "generate/1" do
    setup [:create_episodes]

    test "with valid query returns episodes and description", %{
      episode: episode,
      embedding: embedding,
      response: response
    } do
      _transcription = transcription_fixture(%{podcast_episode_id: episode.id})

      expect(EmbeddingMock, :generate, fn _question_episodes ->
        {:ok, [embedding]}
      end)

      expect(PredictionMock, :predict, fn _messages ->
        {:ok, response}
      end)

      {:ok, {description, context}} = Rag.generate("Who Killed Two Pac Shakur")

      assert description == response

      assert Enum.any?(context, fn context_episode -> context_episode.id == episode.id end) ==
               true
    end
  end
end
