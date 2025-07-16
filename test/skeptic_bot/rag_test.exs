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

  describe "generate/1" do
    setup [:create_embedding]

    test "with valid query returns episodes and description", %{
      embedding: embedding
    } do
      episode = episode_fixture(embedding: embedding)
      _transcription = transcription_fixture(%{podcast_episode_id: episode.id})
      response = "Just a simple response from a large language model"

      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:ok, [embedding]}
      end)

      expect(Rag.MockGenerator, :predict, 2, fn _messages ->
        {:ok, response}
      end)

      {:ok, {description, context}} = Rag.generate("Who Killed Two Pac Shakur")

      assert description == response

      assert Enum.any?(context, fn context_episode -> context_episode.id == episode.id end)
    end

    test "returns error tuple if no episodes fit the threshold", %{
      embedding: embedding
    } do
      expect(Rag.MockGenerator, :predict, fn _messages ->
        {:ok, "Just a simple response from a large language model"}
      end)

      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:ok, [embedding]}
      end)

      assert {:error, :no_episodes_found} = Rag.generate("Who Killed Two Pac Shakur")
    end

    test "returns an error tuple if generation process was unsuccessful" do
      expect(Rag.MockGenerator, :predict, fn _messages ->
        {:ok, "Just a simple response from a large language model"}
      end)

      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:error, "Generation process was unsuccessful"}
      end)

      assert {:error, "Generation process was unsuccessful"} =
               Rag.generate("Who Killed Two Pac Shakur")
    end

    test "returns an error tuple if prediction process was unsuccessful", %{
      embedding: embedding
    } do
      episode = episode_fixture(embedding: embedding)
      _transcription = transcription_fixture(%{podcast_episode_id: episode.id})

      expect(Rag.MockGenerator, :predict, fn _messages ->
        {:ok, "Just a simple response from a large language model"}
      end)

      expect(Rag.MockEmbedder, :generate, fn _question_episodes ->
        {:ok, [embedding]}
      end)

      expect(Rag.MockGenerator, :predict, fn _messages ->
        {:error, "Prediction process was unsuccessful"}
      end)

      assert {:error, "Prediction process was unsuccessful"} =
               Rag.generate("Who Killed Two Pac Shakur")
    end

    test "returns an error tuple if HyDE process was unsuccessful", %{
      embedding: embedding
    } do
      episode = episode_fixture(embedding: embedding)
      _transcription = transcription_fixture(%{podcast_episode_id: episode.id})

      expect(Rag.MockGenerator, :predict, fn _messages ->
        {:error, "HyDE process was unsuccessful"}
      end)

      assert {:error, "HyDE process was unsuccessful"} =
               Rag.generate("Who Killed Two Pac Shakur")
    end
  end
end
