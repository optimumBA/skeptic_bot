defmodule SkepticBot.Podcasts.DescriptionGeneratingWorker do
  @moduledoc """
  Handles generating descriptions for podcast episodes.
  Uses the new description and the episode title to generate a new embedding
  Updates an episode with the newly generated description, summary and embedding.
  """

  use Oban.Worker,
    max_attempts: 5,
    queue: :generating_descriptions,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Rag
  alias SkepticBot.Rag.DescriptionGenerator
  alias SkepticBot.Rag.EmbeddingsGeneratingWorker

  require Logger

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{
        args: %{"id" => id, "episode_status" => status}
      }) do
    with %Episode{} = episode <- Podcasts.get_episode(id),
         {:ok, {description, summary}} <-
           DescriptionGenerator.generate_description_and_summary(episode),
         {:ok, updated_episode} <-
           Podcasts.update_episode(episode, %{description: description, summary: summary}) do
      maybe_enqueue_embedding_worker_job(status, updated_episode)
    else
      nil ->
        Logger.error("Failed to process episode: #{id}, reason: Episode not found")
        {:error, "Episode not found"}

      {:error, reason} ->
        Logger.error("Failed to process episode: #{id}, reason: #{reason}")
        {:error, reason}
    end
  end

  defp maybe_enqueue_embedding_worker_job("existing", episode) do
    text = "passage: " <> episode.title <> " " <> episode.description
    {:ok, [embedding]} = Rag.Embedder.generate(text)
    {:ok, _episode} = Podcasts.update_episode(episode, %{embedding: embedding})
    Podcasts.update_episode(episode, %{embedding: embedding})
    :ok
  end

  defp maybe_enqueue_embedding_worker_job("new", episode) do
    EmbeddingsGeneratingWorker.enqueue(%{"id" => episode.id})
    :ok
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
