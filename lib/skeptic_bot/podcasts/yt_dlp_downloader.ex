defmodule SkepticBot.Podcasts.YtDlpDownloader do
  @moduledoc false

  alias SkepticBot.Podcasts.EpisodeDownloader

  require Logger

  @behaviour EpisodeDownloader

  @impl EpisodeDownloader
  def download(video_url, audio_path) do
    case System.cmd(
           "yt-dlp",
           [
             "-x",
             "--audio-format",
             "mp3",
             "-o",
             "#{audio_path}",
             video_url
           ],
           env: [],
           stderr_to_stdout: true
         ) do
      {_success_message_logs, 0} ->
        {:ok, audio_path}

      {error, 1} ->
        {:error, "Download Error: #{error}"}
    end
  rescue
    e ->
      {:error, "Download error: #{Exception.message(e)}"}
  end
end
