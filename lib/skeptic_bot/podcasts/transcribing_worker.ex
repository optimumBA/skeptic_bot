defmodule SkepticBot.Podcasts.TranscribingWorker do
  @moduledoc """
  Worker responsible for transcribing podcast audio using external transcription services.
  Processes audio files and creates episode transcription records with proper timestamps.
  """

  use Oban.Worker,
    max_attempts: 3,
    queue: :transcribing,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.SummaryGeneratingWorker
  alias SkepticBot.Podcasts.Transcriber
  alias SkepticBot.Repo
  alias SkepticBot.Storage.StorageProvider

  require Logger

  @type job :: Oban.Job.t()

  @type changeset :: Ecto.Changeset.t()
  @type params :: map()

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id, "audio_url" => audio_url}}) do
    case transcribe_episode(id, audio_url) do
      :ok ->
        file_name = Path.basename(audio_url)

        case StorageProvider.delete_file(file_name) do
          :ok ->
            :ok

          {:error, reason} ->
            Logger.error("Failed to delete audio file from Tigris: #{inspect(reason)}")
        end

        SummaryGeneratingWorker.enqueue(%{"id" => id, "episode_status" => "new"})
        :ok

      {:error, reason} ->
        Logger.error("Failed to transcribe episode: #{inspect(reason)}")
        {:error, reason}
    end
  end

  defp transcribe_episode(id, audio_url) do
    case Transcriber.transcribe(audio_url) do
      {:ok, chunks} when is_list(chunks) ->
        persist_transcriptions(id, chunks)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp persist_transcriptions(id, chunks) do
    case Repo.transaction(fn -> insert_transcriptions(id, chunks) end) do
      {:ok, :ok} -> :ok
      {:error, changeset} -> {:error, changeset}
    end
  end

  defp insert_transcriptions(id, chunks) do
    chunks
    |> Stream.reject(&missing_timestamp?/1)
    |> Enum.each(&persist_transcription(id, &1))
  end

  defp missing_timestamp?(%{"timestamp" => [start, _end]}), do: is_nil(start)

  defp persist_transcription(id, %{"text" => text, "timestamp" => [start, _end]}) do
    case Podcasts.create_episode_transcription(%{
           podcast_episode_id: id,
           timestamp: %{months: 0, days: 0, secs: floor(start)},
           transcription: String.trim(text)
         }) do
      {:ok, _transcription} -> :ok
      {:error, changeset} -> Repo.rollback(changeset)
    end
  end

  @spec enqueue(params()) :: {:ok, job()} | {:error, changeset()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
