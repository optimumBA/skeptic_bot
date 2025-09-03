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
  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.EpisodeDownloader
  alias SkepticBot.Podcasts.Transcoder
  alias SkepticBot.Podcasts.TranscribingWorker
  alias SkepticBot.Storage.StorageProvider
  alias SkepticBot.Podcasts.ThumbnailDownloader

  require Logger

  @podcast_lookintoit "Look Into It"
  @podcast_tinfoilhat "Tin Foil Hat"
  @tinfoil_base_thumbnail_url "https://vid.samtripoli.com"

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{
        args: %{"id" => id, "podcast" => podcast, "video_url" => video_url}
      }) do
    with :ok <- store_thumbnail(id, podcast),
         {:ok, audio_url} <- process_with_flame(id, video_url, podcast) do
      TranscribingWorker.enqueue(%{"id" => id, "audio_url" => audio_url})
      :ok
    else
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
        timeout: 4_400_000
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
      with {:ok, _video_path} <- EpisodeDownloader.download(url, video_path, :req),
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

  defp process(id, url, @podcast_lookintoit) do
    tmp_dir = System.tmp_dir!()
    audio_path = Path.join(tmp_dir, "#{id}_.mp3")

    File.rm(audio_path)

    audio_path
    |> Path.dirname()
    |> File.mkdir_p!()

    result =
      with {:ok, _audio_path} <- EpisodeDownloader.download(url, audio_path, :yt_dlp),
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

  defp store_thumbnail(id, @podcast_tinfoilhat) do
    episode = Podcasts.get_episode(id)
    thumbnail_url = @tinfoil_base_thumbnail_url <> episode.thumbnail
    download_and_store_thumbnail(episode, thumbnail_url)
  end

  defp store_thumbnail(id, _podcast) do
    episode = Podcasts.get_episode(id)
    download_and_store_thumbnail(episode, episode.thumbnail)
  end

  defp download_and_store_thumbnail(episode, thumbnail_url) do
    tmp_dir = System.tmp_dir!()
    new_thumbnail_path = Path.join(tmp_dir, "#{episode.id}_#{episode.external_id}.jpg")

    with {:ok, path} <- ThumbnailDownloader.download(thumbnail_url, new_thumbnail_path),
         {:ok, public_url} <- StorageProvider.upload_file(path, "image/jpeg"),
         {:ok, _episode} <- Podcasts.update_episode(episode, %{thumbnail: public_url}),
         :ok <- File.rm(new_thumbnail_path) do
      :ok
    else
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
