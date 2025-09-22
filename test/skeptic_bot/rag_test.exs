defmodule SkepticBot.RagTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Rag

  setup :verify_on_exit!

  defp create_embedding(_attrs) do
    embedding = embedding_fixture()
    %{embedding: embedding}
  end

  describe "generate_embedding/1" do
    setup [:create_embedding]

    test "with valid query returns episodes and description", %{
      embedding: embedding
    } do
      episode = episode_fixture(embedding: embedding)
      _transcription = transcription_fixture(%{podcast_episode_id: episode.id})

      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:ok, [embedding]}
      end)

      {:ok, {context, _embedding}} = Rag.generate_embedding("Who Killed Two Pac Shakur")

      assert Enum.any?(context, fn context_episode -> context_episode.id == episode.id end)
    end

    test "returns error tuple if no episodes fit the threshold", %{
      embedding: embedding
    } do
      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:ok, [embedding]}
      end)

      assert {:error, :no_episodes_found} = Rag.generate_embedding("Who Killed Two Pac Shakur")
    end

    test "returns error tuple if embedding generation fails" do
      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:error, "Embedding Generation failed"}
      end)

      assert {:error, "Embedding Generation failed"} =
               Rag.generate_embedding("Who Killed Two Pac Shakur")
    end
  end

  describe "predict_query/2" do
    test "returns the LLM response if successful" do
      episode = episode_fixture()

      expect(Rag.MockGenerator, :predict, fn _messages, _output_mode ->
        {:ok, "Prediction process was successful"}
      end)

      assert {:ok, "Prediction process was successful"} =
               Rag.predict_query([episode], "Who Killed Two Pac Shakur")
    end

    test "returns an error tuple if prediction process was unsuccessful" do
      episode = episode_fixture()
      query = "American Ponzi with Lee Camp"

      expect(Rag.MockGenerator, :predict, fn _messages, _output_mode ->
        {:error, "Prediction process was unsuccessful"}
      end)

      assert {:error, "Prediction process was unsuccessful"} =
               Rag.predict_query([episode], query)
    end
  end
end
