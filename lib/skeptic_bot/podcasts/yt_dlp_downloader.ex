defmodule SkepticBot.Podcasts.YtDlpDownloader do
  @moduledoc false

  alias SkepticBot.Podcasts.Downloader

  require Logger

  @behaviour Downloader

  @impl Downloader
  def download(video_url, audio_path) do
    cookie_file = Application.get_env(:skeptic_bot, :youtube_cookie_file_path)
    proxy = Application.get_env(:skeptic_bot, :ytdlp_proxy)

    proxy_args = if proxy, do: ["--proxy", proxy], else: []

    case System.cmd(
           "yt-dlp",
           [
             "--cache-dir",
             System.tmp_dir!(),
             "--cookies",
             cookie_file
           ] ++
             proxy_args ++
             [
               "-x",
               "--audio-format",
               "mp3",
               "-o",
               "#{audio_path}",
               video_url
             ],
           env: [{"PYTHONUTF8", "1"}],
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
