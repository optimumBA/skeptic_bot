defmodule SkepticBot.YtDlp.YtDlpChannelClient do
  @moduledoc """
  Getting channel data using yt-dlp
  """

  alias SkepticBot.YtDlp.ChannelClient

  require Logger

  @behaviour ChannelClient

  @impl ChannelClient
  def get_channel_data(channel) do
    case System.cmd(
           "yt-dlp",
           [
             "--print",
             "%(title)s$$%(duration)s$$%(thumbnail)s$$%(webpage_url)s",
             channel
           ],
           env: [{"PYTHONUTF8", "1"}],
           stderr_to_stdout: true
         ) do
      {result, 0} ->
        {:ok, result}

      {error, 1} ->
        {:error, error}
    end
  end

  @impl ChannelClient
  def get_channel_data_from_port(date, channel) do
    cookie_file = Application.get_env(:skeptic_bot, :youtube_cookie_file_path)

    cmd =
      "env PYTHONUTF8=1 yt-dlp --cache-dir #{System.tmp_dir!()} --date #{date} --cookies #{cookie_file} --print \"%(title)s~~%(duration)s~~%(thumbnail)s~~%(webpage_url)s\" #{channel}"

    port = Port.open({:spawn, cmd}, [:binary, :stderr_to_stdout, :exit_status])
    Process.send_after(self(), {:close_port, port}, :timer.minutes(1))
    port
  end
end
