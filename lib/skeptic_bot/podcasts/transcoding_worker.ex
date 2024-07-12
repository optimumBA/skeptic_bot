defmodule SkepticBot.Podcasts.TranscodingWorker do
  use Oban.Worker,
    queue: :transcoding,
    unique: [period: :infinity, states: Oban.Job.states()]

  alias SkepticBot.Podcasts.TranscribingWorker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    transcode(id)
    TranscribingWorker.enqueue(%{"id" => id})

    :ok
  end

  defp transcode(id) do
    dir = Path.join(Application.app_dir(:skeptic_bot, "priv"), "podcasts")
    video_dir = Path.join(dir, "video")
    audio_dir = Path.join(dir, "audio")
    File.mkdir_p!(audio_dir)
    video_file_path = Path.join(video_dir, "#{id}.mp4")
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
  end

  def enqueue(attrs) do
    attrs
    |> __MODULE__.new()
    |> Oban.insert()
  end
end
