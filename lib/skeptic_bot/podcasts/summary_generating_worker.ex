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
  alias SkepticBot.Rag.EmbeddingsGeneratingWorker
  alias SkepticBot.Rag.SummaryGenerator

  require Logger

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{
        args: %{"id" => id, "episode_status" => status}
      }) do
    with {:ok, episode} <- fetch_episode(id),
         {:ok, {teaser, summary}} <-
           SummaryGenerator.generate_teaser_and_summary(episode),
         {:ok, _updated_episode} <-
           Podcasts.update_episode(episode, %{summary: summary, teaser: teaser}) do
      EmbeddingsGeneratingWorker.enqueue(%{"id" => episode.id, "status" => status})
      :ok
    else
      {:error, reason} ->
        Logger.error("Failed to process episode: #{id}, reason: #{reason}")
        {:error, reason}
    end
  end

  defp fetch_episode(episode_id) do
    case Podcasts.get_episode(episode_id) do
      nil -> {:error, "Episode not found"}
      episode -> {:ok, episode}
    end
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
