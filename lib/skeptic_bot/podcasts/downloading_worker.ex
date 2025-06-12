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
  alias SkepticBot.Podcasts.TranscribingWorker
  alias SkepticBot.Storage.Tigris

  require Logger

  @callback process_with_flame(String.t(), String.t(), String.t()) ::
              {:ok, String.t()} | {:error, String.t()}
  @type job :: Oban.Job.t()

  @url "https://vid.samtripoli.com/download/streaming-playlists/hls/videos/<external_id>-0-fragmented.mp4"

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{args: %{"id" => id, "external_id" => external_id}}) do
    url = String.replace(@url, "<external_id>", external_id)

    case get_downloader_module().process_with_flame(id, url, external_id) do
      {:ok, audio_url} ->
        TranscribingWorker.enqueue(%{"id" => id, "audio_url" => audio_url})
        :ok

      {:error, reason} ->
        Logger.error("Failed to process episode: #{id}, reason: #{reason}")
        {:error, reason}
    end
  end

  @spec process_with_flame(String.t(), String.t(), String.t()) ::
          {:ok, String.t()} | {:error, String.t()}

  def process_with_flame(id, url, external_id) do
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

    download_result = download_video_file(url, video_path)

    result =
      case download_result do
        {:ok, _audio_path} -> process_video(video_path, audio_path)
        {:error, _reason} = error -> error
      end

    File.rm(video_path)
    File.rm(audio_path)

    result
  end

  defp download_video_file(url, path) do
    case Req.get(
           url,
           raw: true,
           receive_timeout: 600_000,
           connect_options: [timeout: 60_000],
           retry: :transient,
           max_retries: 3,
           into: File.stream!(path, [:write, :binary, :delayed_write])
         ) do
      {:ok, %{status: status}} when status in 200..299 ->
        {:ok, path}

      {:ok, %{status: status}} ->
        {:error, "HTTP error: status #{status}"}

      error ->
        {:error, "Request error: #{inspect(error)}"}
    end
  rescue
    e -> {:error, "Download error: #{Exception.message(e)}"}
  end

  defp process_video(video_path, audio_path) do
    case System.cmd(
           "ffmpeg",
           [
             "-hide_banner",
             "-i",
             video_path,
             "-b:a",
             "192K",
             "-vn",
             audio_path
           ],
           env: [],
           stderr_to_stdout: true
         ) do
      {_result, 0} ->
        Tigris.upload_file(audio_path)

      {_result, exit_code} ->
        {:error, "Transcoding failed with exit code: #{exit_code}"}
    end
  rescue
    e -> {:error, "Processing error: #{Exception.message(e)}"}
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end

  defp get_downloader_module do
    Application.get_env(:skeptic_bot, :downloader_module, SkepticBot.Podcasts.DownloadingWorker)
  end
end
