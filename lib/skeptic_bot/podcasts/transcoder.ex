defmodule SkepticBot.Podcasts.Transcoder do
  @moduledoc false

  alias SkepticBot.Podcasts.FfmpegTranscoder

  @type path :: String.t()
  @type reason :: String.t()

  @callback transcode_video(path(), path()) :: :ok | {:error, reason()}

  @spec transcode_video(path(), path()) :: :ok | {:error, reason()}
  def transcode_video(video_path, audio_path), do: impl().transcode_video(video_path, audio_path)

  defp impl, do: Application.get_env(:skeptic_bot, :transcoder, FfmpegTranscoder)
end
