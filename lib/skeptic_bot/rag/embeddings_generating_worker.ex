defmodule SkepticBot.Rag.EmbeddingsGeneratingWorker do
  use Oban.Worker,
    max_attempts: 3,
    queue: :generating_embeddings,
    unique: [period: :infinity, states: Oban.Job.states()]

  require Logger

  alias SkepticBot.Podcasts
  alias SkepticBot.Rag.Embedding

  @batch_size 32

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    generate_embeddings(id)
  end

  defp generate_embeddings(episode_id) do
    with {:ok, episode} <- fetch_episode(episode_id),
         {:ok, _} <- generate_episode_embedding(episode),
         {:ok, _} <- generate_transcription_embeddings(episode_id) do
      :ok
    else
      {:error, reason} ->
        Logger.error(
          "Failed to generate embeddings for episode #{episode_id}: #{inspect(reason)}"
        )

        {:error, reason}

      nil ->
        {:error, "Episode not found"}
    end
  end

  defp fetch_episode(episode_id) do
    case Podcasts.get_episode(episode_id) do
      nil -> {:error, "Episode not found"}
      episode -> {:ok, episode}
    end
  end

  defp generate_episode_embedding(episode) do
    text = "passage: " <> episode.title <> " " <> (episode.description || "")

    with {:ok, [embedding]} <- Embedding.generate(text),
         {:ok, updated_episode} <- Podcasts.update_episode(episode, %{embedding: embedding}) do
      {:ok, updated_episode}
    end
  end

  defp generate_transcription_embeddings(episode_id) do
    Podcasts.while_streaming_episode_transcriptions(
      episode_id,
      @batch_size,
      &process_transcription_batch/1
    )
  end

  defp process_transcription_batch(episode_transcriptions) do
    texts = Enum.map(episode_transcriptions, &("passage: " <> &1.transcription))

    with {:ok, embeddings} <- Embedding.generate(texts) do
      episode_transcriptions
      |> Enum.zip(List.wrap(embeddings))
      |> Enum.map(&update_transcription_embedding/1)
      |> Enum.find({:error, "Failed to update transcription"}, &match?({:error, _}, &1))
    end
  end

  defp update_transcription_embedding({episode_transcription, embedding}) do
    case Podcasts.update_episode_transcription(episode_transcription, %{embedding: embedding}) do
      {:ok, _updated} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
