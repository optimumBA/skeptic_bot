defmodule SkepticBot.Podcasts.DescriptionGeneratingWorker do
  @moduledoc """
  Handles generating descriptions for podcast episodes.
  Updates an episode with the newly generated description.
  """

  use Oban.Worker,
    max_attempts: 5,
    queue: :downloading,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.DownloadingRunner
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
      Podcasts.update_episode(episode, %{description: description})
      :ok
    else
      {:error, reason} ->
        Logger.error("Failed to process episode: #{id}, reason: #{reason}")
        {:error, reason}
    end
  end

  defp process_with_flame(episode) do
    result =
      FLAME.call(
        DownloadingRunner,
        fn -> DescriptionGenerator.generate_description(episode) end,
        timeout: 1_800_000
      )

    case result do
      {:ok, description} -> {:ok, description}
      {:error, reason} -> {:error, reason}
    end
  rescue
    e ->
      Logger.error("FLAME process failed: #{Exception.message(e)}")
      {:error, "FLAME processing failed: #{Exception.message(e)}"}
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
