defmodule SkepticBot.Podcasts.TranscribingWorker do
  use Oban.Worker,
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
    dir = Path.join([Application.app_dir(:skeptic_bot, "priv"), "podcasts", "audio"])
    File.mkdir_p!(dir)
    path = Path.join(dir, "#{id}.mp3")

    case download_file(audio_url, path) do
      :ok ->
        for chunk <- Transcription.transcribe(path) do
          Podcasts.create_episode_transcription(%{
            podcast_episode_id: id,
            timestamp: %{months: 0, days: 0, secs: floor(chunk.start_timestamp_seconds)},
            transcription: chunk.text
          })
        end

        File.rm(path)
        :ok

      {:error, reason} ->
        {:error, "Failed to download audio file: #{reason}"}
    end
  end

  defp download_file(url, destination) do
    try do
      Tigris.new()
      |> Req.get!(
        url: Path.basename(url),
        into: File.stream!(destination)
      )

      case File.stat(destination) do
        {:ok, %{size: size}} when size > 0 ->
          :ok

        {:ok, %{size: 0}} ->
          Logger.error("Downloaded file is empty")
          {:error, "Downloaded file is empty"}

        {:error, reason} ->
          Logger.error("Failed to stat downloaded file: #{inspect(reason)}")
          {:error, "Failed to verify downloaded file"}
      end
    rescue
      e ->
        Logger.error("Error downloading file: #{Exception.message(e)}")
        {:error, Exception.message(e)}
    end
  end

  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
