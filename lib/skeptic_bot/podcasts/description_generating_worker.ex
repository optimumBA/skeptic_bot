defmodule SkepticBot.Podcasts.DescriptionGeneratingWorker do
  @moduledoc """
  Handles generating descriptions for podcast episodes.
  Updates an episode with the newly generated description.
  """

  use Oban.Worker,
    max_attempts: 5,
    queue: :generating_descriptions,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Rag.DescriptionGenerator

  require Logger

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{
        args: %{"id" => id}
      }) do
    with %Episode{} = episode <- Podcasts.get_episode(id),
         {:ok, description} <- process_with_flame(episode) do
      {:ok, _episode} = Podcasts.update_episode(episode, %{description: description})
      Logger.info(description)
      :ok
    else
      nil ->
        Logger.error("Failed to process episode: #{id}, reason: Episode not found")
        {:error, "Episode not found"}

      {:error, reason} ->
        Logger.error("Failed to process episode: #{id}, reason: #{reason}")
        {:error, reason}
    end
  end

  defp process_with_flame(episode) do
    case DescriptionGenerator.generate_description(episode) do
      {:ok, description} -> {:ok, description}
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
