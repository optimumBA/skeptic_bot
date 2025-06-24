defmodule SkepticBot.Podcasts.FfmpegTranscoder do
  @moduledoc false
  alias SkepticBot.Podcasts.Transcoder

  @behaviour Transcoder

  @impl Transcoder
  def transcode_video(video_path, audio_path) do
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
        :ok

      {_result, exit_code} ->
        {:error, "Transcoding failed with exit code: #{exit_code}"}
    end
  end
end
