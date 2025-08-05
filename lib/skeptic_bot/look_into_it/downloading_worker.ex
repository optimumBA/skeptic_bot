defmodule SkepticBot.LookIntoIt.DownloadingWorker do
  @moduledoc """
  Handles combined downloading and transcoding of podcast episodes from external sources.
  Downloads the media file and uploads the audio to Tigris.
  Uses FLAME to handle both processes in a separate memory space.
  """

  use Oban.Worker,
    max_attempts: 5,
    queue: :downloading,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.DownloadingRunner
  alias SkepticBot.LookIntoIt.Downloader
  alias SkepticBot.Podcasts.TranscribingWorker
  alias SkepticBot.Storage.StorageProvider

  require Logger

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{args: %{"id" => id, "video_url" => video_url}}) do
    case process_with_flame(id, video_url) do
      {:ok, audio_url} ->
        TranscribingWorker.enqueue(%{"id" => id, "audio_url" => audio_url})
        :ok

      {:error, reason} ->
        Logger.error("Failed to process episode: #{id}, reason: #{reason}")
        {:error, reason}
    end
  end

  defp process_with_flame(id, video_url) do
    FLAME.call(
      DownloadingRunner,
      fn -> download_and_upload(id, video_url) end,
      timeout: 1_800_000
    )
  rescue
    e ->
      Logger.error("FLAME process failed: #{Exception.message(e)}")
      {:error, "FLAME processing failed: #{Exception.message(e)}"}
  end

  defp download_and_upload(id, video_url) do
    tmp_dir = System.tmp_dir!()
    audio_path = Path.join(tmp_dir, "#{id}_.mp3")

    File.rm(audio_path)

    audio_path
    |> Path.dirname()
    |> File.mkdir_p!()

    result =
      with {:ok, _audio_path} <- Downloader.download(video_url, audio_path),
           {:ok, url} <- StorageProvider.upload_file(audio_path) do
        {:ok, url}
      else
        {:error, reason} ->
          Logger.error("download_and_upload/2 failed with reason : #{reason}")
          {:error, reason}
      end

    File.rm(audio_path)

    result
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
