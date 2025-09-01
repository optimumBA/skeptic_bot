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

  alias SkepticBot.DownloadingRunner
  alias SkepticBot.Podcasts.Downloader
  alias SkepticBot.Podcasts.Transcoder
  alias SkepticBot.Podcasts.TranscribingWorker
  alias SkepticBot.Storage.StorageProvider

  require Logger

  @podcast_candace "Candace"
  @podcast_lookintoit "Look Into It"
  @podcast_tinfoilhat "Tin Foil Hat"

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{
        args: %{"id" => id, "podcast" => podcast, "video_url" => video_url}
      }) do
    case process_with_flame(id, video_url, podcast) do
      {:ok, audio_url} ->
        TranscribingWorker.enqueue(%{"id" => id, "audio_url" => audio_url})
        :ok

      {:error, reason} ->
        Logger.error("Failed to process episode: #{id}, reason: #{reason}")
        {:error, reason}
    end
  end

  defp process_with_flame(id, video_url, podcast) do
    result =
      FLAME.call(
        DownloadingRunner,
        fn -> process(id, video_url, podcast) end,
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

  defp process(id, url, @podcast_tinfoilhat) do
    tmp_dir = System.tmp_dir!()
    video_path = Path.join(tmp_dir, "#{id}.mp4")
    audio_path = Path.join(tmp_dir, "#{id}.mp3")

    File.rm(video_path)
    File.rm(audio_path)

    video_path
    |> Path.dirname()
    |> File.mkdir_p!()

    result =
      with {:ok, _video_path} <- Downloader.download(url, video_path, :req),
           :ok <- Transcoder.transcode_video(video_path, audio_path),
           {:ok, url} <- StorageProvider.upload_file(audio_path) do
        {:ok, url}
      else
        {:error, reason} ->
          Logger.error("process/3 failed with Reason: #{reason}")
          {:error, reason}
      end

    File.rm(video_path)
    File.rm(audio_path)

    result
  end

  defp process(id, url, podcast)
       when podcast in [@podcast_candace, @podcast_lookintoit] do
    tmp_dir = System.tmp_dir!()
    audio_path = Path.join(tmp_dir, "#{id}_.mp3")

    File.rm(audio_path)

    audio_path
    |> Path.dirname()
    |> File.mkdir_p!()

    result =
      with {:ok, _audio_path} <- Downloader.download(url, audio_path, :yt_dlp),
           {:ok, url} <- StorageProvider.upload_file(audio_path) do
        {:ok, url}
      else
        {:error, reason} ->
          Logger.error("process/3 failed with Reason: #{reason}")
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
