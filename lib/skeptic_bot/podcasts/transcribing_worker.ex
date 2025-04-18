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
  alias SkepticBot.Rag.EmbeddingsGeneratingWorker
  alias SkepticBot.Storage.Tigris
  alias SkepticBot.Transcription

  require Logger

  @type audio_url :: String.t()
  @type id :: String.t()
  @type job :: Oban.Job.t()

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{args: %{"id" => id, "audio_url" => audio_url}}) do
    case transcribe_episode(id, audio_url) do
      :ok ->
        file_name = Path.basename(audio_url)

        case Tigris.delete_file(file_name) do
          :ok ->
            :ok

          {:error, reason} ->
            Logger.error("Failed to delete audio file from Tigris: #{reason}")
        end

        EmbeddingsGeneratingWorker.enqueue(%{"id" => id})
        :ok

      {:error, reason} ->
        Logger.error("Failed to transcribe episode: #{reason}")
        {:error, reason}
    end
  end

  @spec transcribe_episode(id(), audio_url()) :: :ok | {:error, any()}
  defp transcribe_episode(id, audio_url) do
    case Transcription.transcribe(audio_url) do
      {:ok, chunks} when is_list(chunks) ->
        chunks
        |> Stream.reject(fn %{"timestamp" => [start, _end]} -> is_nil(start) end)
        |> Enum.each(fn %{"text" => text, "timestamp" => [start, _end]} ->
          Podcasts.create_episode_transcription(%{
            podcast_episode_id: id,
            timestamp: %{months: 0, days: 0, secs: floor(start)},
            transcription: String.trim(text)
          })
        end)

        :ok

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
