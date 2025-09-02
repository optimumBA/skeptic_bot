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
           env: [],
           stderr_to_stdout: true
         ) do
      {result, 0} ->
        {:ok, result}

      {error, 1} ->
        {:error, error}
    end
  end

  @impl ChannelClient
  def get_channel_data_from_port(date, cookie_file, channel) do
    cmd =
      "yt-dlp --cache-dir /tmp/yt-cache --date #{date} --cookies #{cookie_file} --print \"%(title)s~~%(duration)s~~%(thumbnail)s~~%(webpage_url)s\" #{channel}"

    Port.open({:spawn, cmd}, [:binary, :stderr_to_stdout, :exit_status])
  end
end
