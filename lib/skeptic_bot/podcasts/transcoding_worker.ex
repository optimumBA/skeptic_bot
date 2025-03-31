defmodule SkepticBot.Podcasts.TranscodingWorker do
  use Oban.Worker,
    max_attempts: 5,
    queue: :transcoding,
    unique: [period: :infinity, states: Oban.Job.states()]

  require Logger

  alias SkepticBot.Podcasts.TranscribingWorker
  alias SkepticBot.Storage.Tigris

  @audio_extensions [".mp3", ".wav", ".m4a", ".aac", ".ogg", ".flac"]

  @impl Oban.Worker
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

  defp get_source_file_path(id) do
    dir = Path.join(Application.app_dir(:skeptic_bot, "priv"), "podcasts")
    video_path = Path.join([dir, "video", "#{id}.mp4"])

    audio_paths =
      Enum.map(@audio_extensions, fn ext ->
        Path.join([dir, "audio", "#{id}#{ext}"])
      end)

    audio_path = Enum.find(audio_paths, fn path -> File.exists?(path) end)

    cond do
      File.exists?(video_path) -> video_path
      audio_path -> audio_path
      true -> video_path
    end
  end

  defp determine_file_type(file_path) do
    extension = Path.extname(file_path)

    cond do
      extension == ".mp4" ->
        :video

      extension in @audio_extensions ->
        :audio

      true ->
        {output, 0} = System.cmd("file", ["--mime-type", "-b", file_path])
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

  defp transcode_video_to_audio(id, video_file_path) do
    dir = Path.join(Application.app_dir(:skeptic_bot, "priv"), "podcasts")
    audio_dir = Path.join(dir, "audio")
    File.mkdir_p!(audio_dir)
    audio_file_path = Path.join(audio_dir, "#{id}.mp3")

    File.rm(audio_file_path)

    System.cmd("ffmpeg", [
      "-hide_banner",
      "-i",
      video_file_path,
      "-b:a",
      "192K",
      "-vn",
      audio_file_path
    ])

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

  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
