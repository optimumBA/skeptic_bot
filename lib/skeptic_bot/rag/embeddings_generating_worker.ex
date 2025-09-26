defmodule SkepticBot.Rag.EmbeddingsGeneratingWorker do
  @moduledoc """
  Processes podcast episodes to generate vector embeddings for both episode metadata and transcriptions.
  These embeddings enable semantic search and retrieval capabilities for the RAG system.
  """

  use Oban.Worker,
    max_attempts: 3,
    queue: :generating_embeddings,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.Podcasts
  alias SkepticBot.Rag.Embedder

  require Logger

  @type embedding :: [float()]
  @type episode :: Podcasts.Episode.t()
  @type episode_id :: String.t()
  @type episode_transcription :: Podcasts.EpisodeTranscription.t()
  @type job :: Oban.Job.t()
  @batch_size 32

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{args: %{"id" => id}}) do
    generate_embeddings(id)
  end

  @spec generate_embeddings(episode_id()) :: :ok | {:error, String.t()}
  defp generate_embeddings(episode_id) do
    with {:ok, episode} <- fetch_episode(episode_id),
         {:ok, _result} <- generate_episode_embedding(episode),
         {:ok, _count} <- generate_transcription_embeddings(episode_id) do
      :ok
    else
      {:error, reason} ->
        Logger.error(
          "Failed to generate embeddings for episode #{episode_id}: #{inspect(reason)}"
        )

        {:error, reason}
    end
  end

  @spec fetch_episode(episode_id()) :: {:ok, episode()} | {:error, String.t()}
  defp fetch_episode(episode_id) do
    case Podcasts.get_episode(episode_id) do
      nil -> {:error, "Episode not found"}
      episode -> {:ok, episode}
    end
  end

  @spec generate_episode_embedding(episode()) :: {:ok, episode()} | {:error, any()}
  defp generate_episode_embedding(episode) do
    text = "passage: " <> episode.title <> " " <> (episode.summary || "")

    with {:ok, [embedding]} <- Embedder.generate(text) do
      Podcasts.update_episode(episode, %{embedding: embedding})
    end
  end

  @spec generate_transcription_embeddings(episode_id()) :: {:ok, integer()} | {:error, any()}
  defp generate_transcription_embeddings(episode_id) do
    Podcasts.while_streaming_episode_transcriptions(
      episode_id,
      @batch_size,
      &process_transcription_batch/1
    )
  end

  @spec process_transcription_batch([episode_transcription()]) :: :ok | {:error, any()}
  defp process_transcription_batch(episode_transcriptions) do
    texts = Enum.map(episode_transcriptions, &("passage: " <> &1.transcription))

    with {:ok, embeddings} <- Embedder.generate(texts) do
      episode_transcriptions
      |> Enum.zip(List.wrap(embeddings))
      |> Enum.map(&update_transcription_embedding/1)
      |> Enum.find({:error, "Failed to update transcription"}, &match?({:error, _reason}, &1))
    end
  end

  @spec update_transcription_embedding({episode_transcription(), embedding()}) ::
          :ok | {:error, any()}
  defp update_transcription_embedding({episode_transcription, embedding}) do
    case Podcasts.update_episode_transcription(episode_transcription, %{embedding: embedding}) do
      {:ok, _updated} -> :ok
      {:error, reason} -> {:error, reason}
    end
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
