defmodule SkepticBot.Podcasts.TranscribingWorker do
  use Oban.Worker,
    max_attempts: 3,
    queue: :transcribing,
    unique: [period: :infinity, states: Oban.Job.states()]

  require Logger

  alias SkepticBot.Podcasts
  alias SkepticBot.Rag.EmbeddingsGeneratingWorker
  alias SkepticBot.Storage.Tigris
  alias SkepticBot.Transcription

  @impl Oban.Worker
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

  defp transcribe_episode(id, audio_url) do
    case Transcription.transcribe(audio_url) do
      {:ok, chunks} when is_list(chunks) ->
        Enum.each(chunks, fn %{"text" => text, "timestamp" => [start, _end]} ->
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

  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
