defmodule SkepticBot.Podcasts.DownloadingWorker do
  @moduledoc """
  Handles combined downloading and transcoding of podcast episodes from external sources.
  Downloads the media file, transcodes it, and uploads the audio to Tigris.
  Uses FLAME to handle both processes in a separate memory space.
  """

  use Oban.Worker,
    max_attempts: 5,
    queue: :downloading,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.Podcasts.Downloader
  alias SkepticBot.Podcasts.Transcoder
  alias SkepticBot.Podcasts.TranscribingWorker
  alias SkepticBot.Storage.StorageProvider

  require Logger

  @type job :: Oban.Job.t()

  @url "https://vid.samtripoli.com/download/streaming-playlists/hls/videos/<external_id>-0-fragmented.mp4"

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{args: %{"id" => id, "external_id" => external_id}}) do
    url = String.replace(@url, "<external_id>", external_id)

    case process_with_flame(id, url, external_id) do
      {:ok, audio_url} ->
        TranscribingWorker.enqueue(%{"id" => id, "audio_url" => audio_url})
        :ok

      {:error, reason} ->
        Logger.error("Failed to process episode: #{id}, reason: #{reason}")
        {:error, reason}
    end
  end

  defp process_with_flame(id, url, external_id) do
    result =
      FLAME.call(
        DownloadingRunner,
        fn -> download_transcode_and_upload(id, url, external_id) end,
        timeout: 1_800_000
      )

    case result do
      {:ok, audio_url} -> {:ok, audio_url}
      {:error, reason} -> {:error, reason}
    end
  rescue
    e ->
      Logger.error("FLAME process failed: #{Exception.message(e)}")
      {:error, "FLAME processing failed: #{Exception.message(e)}"}
  end

  defp download_transcode_and_upload(id, url, external_id) do
    tmp_dir = System.tmp_dir!()
    video_path = Path.join(tmp_dir, "#{id}_#{external_id}.mp4")
    audio_path = Path.join(tmp_dir, "#{id}_#{external_id}.mp3")

    File.rm(video_path)
    File.rm(audio_path)

    video_path
    |> Path.dirname()
    |> File.mkdir_p!()

    result =
      with {:ok, _video_path} <- Downloader.download(url, video_path),
           :ok <- Transcoder.transcode_video(video_path, audio_path),
           {:ok, url} <- StorageProvider.upload_file(audio_path) do
        url
      else
        {:error, reason} ->
          Logger.error("Transcoding video failed")
          {:error, reason}
      end

    File.rm(video_path)
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
