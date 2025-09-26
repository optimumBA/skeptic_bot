defmodule SkepticBot.Podcasts.SummaryGeneratingWorker do
  @moduledoc """
  Handles generating summary for podcast episodes.
  Uses the new summary and the episode title to generate a new embedding
  Updates an episode with the newly generated summary, teaser and embedding.
  """

  use Oban.Worker,
    max_attempts: 5,
    queue: :generating_summaries,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Rag
  alias SkepticBot.Rag.EmbeddingsGeneratingWorker
  alias SkepticBot.Rag.SummaryGenerator

  require Logger

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{
        args: %{"id" => id, "episode_status" => status}
      }) do
    with %Episode{} = episode <- Podcasts.get_episode(id),
         {:ok, {teaser, summary}} <-
           SummaryGenerator.generate_teaser_and_summary(episode),
         {:ok, updated_episode} <-
           Podcasts.update_episode(episode, %{summary: summary, teaser: teaser}) do
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
    with text <- "passage: " <> episode.title <> " " <> episode.summary,
         {:ok, [embedding]} <-
           Rag.Embedder.generate(text),
         {:ok, _episode} <- Podcasts.update_episode(episode, %{embedding: embedding}) do
      :ok
    else
      {:error, reason} ->
        Logger.error("Failed to update episode embedding, reason: #{reason}")
        {:error, reason}
    end
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
