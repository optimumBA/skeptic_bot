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
  alias SkepticBot.Podcasts.Downloader
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Podcasts.ThumbnailDownloader
  alias SkepticBot.Podcasts.Transcoder
  alias SkepticBot.Podcasts.TranscribingWorker
  alias SkepticBot.Storage.StorageProvider

  require Logger

  @podcast_brokensimulation "Broken Simulation"
  @podcast_candace "Candace"
  @podcast_cashdaddies "Cash Daddies"
  @podcast_deepwaters "Deep Waters"
  @podcast_doomscrollin "Doom Scrollin"
  @podcast_lookintoit "Look Into It"
  @podcast_nephilimdeathsquad "Nephilim Death Squad"
  @podcast_tinfoilhat "Tin Foil Hat"
  @podcast_unionoftheunwanted "Union of the Unwanted"
  @podcast_zerowithsamtripoli "Zero with Sam Tripoli"
  @podcast_samtripoliwebsite [
    @podcast_cashdaddies,
    @podcast_doomscrollin,
    @podcast_tinfoilhat,
    @podcast_unionoftheunwanted,
    @podcast_zerowithsamtripoli
  ]

  @type job :: Oban.Job.t()

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{
        args: %{"id" => id, "podcast" => podcast, "video_url" => video_url}
      }) do
    with {:ok, audio_url} <- process_with_flame(id, video_url, podcast),
         %Episode{} = episode <- Podcasts.get_episode(id),
         :ok <- maybe_download_thumbnail(episode.thumbnail, episode, podcast) do
      TranscribingWorker.enqueue(%{"id" => id, "audio_url" => audio_url})
      :ok
    else
      nil ->
        Logger.error("Failed to download thumbnail for episode: #{id}")
        {:error, "Episode not found"}

      {:error, reason} ->
        Logger.error("Failed to process episode: #{id}, reason: #{reason}")

        Appsignal.send_error(
          %RuntimeError{message: "Episode #{id} processing failed: #{reason}"},
          []
        )

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

  defp process(id, url, name) when name in @podcast_samtripoliwebsite do
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
           {:ok, url} <- StorageProvider.upload_file(audio_path, "audio/mpeg") do
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
       when podcast in [
              @podcast_brokensimulation,
              @podcast_candace,
              @podcast_deepwaters,
              @podcast_lookintoit,
              @podcast_nephilimdeathsquad
            ] do
    tmp_dir = System.tmp_dir!()
    audio_path = Path.join(tmp_dir, "#{id}_.mp3")

    File.rm(audio_path)

    audio_path
    |> Path.dirname()
    |> File.mkdir_p!()

    result =
      with {:ok, _audio_path} <- Downloader.download(url, audio_path, :yt_dlp),
           {:ok, url} <- StorageProvider.upload_file(audio_path, "audio/mpeg") do
        {:ok, url}
      else
        {:error, reason} ->
          Logger.error("process/3 failed with Reason: #{reason}")
          {:error, reason}
      end

    File.rm(audio_path)

    result
  end

  defp maybe_download_thumbnail(
         <<"https://skeptic-bot.fly.storage.tigris.dev/", _remainder_thumbnail::binary>>,
         _episode,
         _podcast
       ),
       do: :ok

  defp maybe_download_thumbnail(_thumbnail, episode, podcast),
    do: ThumbnailDownloader.store_thumbnail(episode, podcast)

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
