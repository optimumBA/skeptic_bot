defmodule SkepticBot.Podcasts.TranscodingWorker do
  @moduledoc """
  Handles transcoding of podcast episodes from video to audio formats.
  Prepares audio for transcription by converting, optimizing, and uploading to storage.
  """

  use Oban.Worker,
    max_attempts: 5,
    queue: :transcoding,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.Podcasts.TranscribingWorker
  alias SkepticBot.Storage.Tigris

  require Logger

  @type file_type :: :audio | :unknown | :video
  @type id :: String.t()
  @type job :: Oban.Job.t()
  @type source_file_path :: String.t()

  @audio_extensions [".mp3", ".wav", ".m4a", ".aac", ".ogg", ".flac"]

  @impl Oban.Worker
  @spec perform(job()) :: :ok | {:error, String.t()}
  def perform(%Oban.Job{args: %{"id" => id}}) do
    source_file_path = get_source_file_path(id)

    if File.exists?(source_file_path) do
      file_type = determine_file_type(source_file_path)
      process_file(id, source_file_path, file_type)
    else
      Logger.error("Source file not found: #{source_file_path}")
      {:error, "Source file not found"}
    end
  end

  @spec get_source_file_path(id()) :: source_file_path()
  defp get_source_file_path(id) do
    dir =
      :skeptic_bot
      |> Application.app_dir("priv")
      |> Path.join("podcasts")

    video_path = Path.join([dir, "video", "#{id}.mp4"])

    audio_paths =
      Enum.map(@audio_extensions, fn ext ->
        Path.join([dir, "audio", "#{id}#{ext}"])
      end)

    audio_path = Enum.find(audio_paths, &File.exists?/1)

    cond do
      File.exists?(video_path) -> video_path
      audio_path -> audio_path
      true -> video_path
    end
  end

  @spec determine_file_type(source_file_path()) :: file_type()
  defp determine_file_type(file_path) do
    extension = Path.extname(file_path)

    cond do
      extension == ".mp4" ->
        :video

      extension in @audio_extensions ->
        :audio

      true ->
        {output, 0} = System.cmd("file", ["--mime-type", "-b", file_path], env: [])
        mime_type = String.trim(output)

        cond do
          String.starts_with?(mime_type, "video/") -> :video
          String.starts_with?(mime_type, "audio/") -> :audio
          true -> :unknown
        end
    end
  end

  defp process_file(id, source_file_path, :video) do
    audio_file_path = transcode_video_to_audio(id, source_file_path)
    upload_and_enqueue(id, audio_file_path)
  end

  defp process_file(id, source_file_path, :audio) do
    upload_and_enqueue(id, source_file_path)
  end

  defp process_file(id, source_file_path, :unknown) do
    Logger.warning("Unknown file type for #{source_file_path}, attempting to process as video")
    process_file(id, source_file_path, :video)
  end

  @spec transcode_video_to_audio(id(), source_file_path()) :: source_file_path()
  defp transcode_video_to_audio(id, video_file_path) do
    audio_dir =
      :skeptic_bot
      |> Application.app_dir("priv")
      |> Path.join("podcasts")
      |> Path.join("audio")

    File.mkdir_p!(audio_dir)
    audio_file_path = Path.join(audio_dir, "#{id}.mp3")
    File.rm(audio_file_path)

    System.cmd(
      "ffmpeg",
      [
        "-hide_banner",
        "-i",
        video_file_path,
        "-b:a",
        "192K",
        "-vn",
        audio_file_path
      ],
      env: []
    )

    File.rm!(video_file_path)

    audio_file_path
  end

  defp upload_and_enqueue(id, audio_file_path) do
    case Tigris.upload_file(audio_file_path) do
      {:ok, public_url} ->
        TranscribingWorker.enqueue(%{"id" => id, "audio_url" => public_url})

        File.rm(audio_file_path)
        :ok

      {:error, reason} ->
        Logger.error("Failed to upload audio file to Tigris: #{reason}")
        {:error, "Failed to upload audio file"}
    end
  end

  @spec enqueue(map()) :: {:ok, job()} | {:error, Ecto.Changeset.t()}
  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
