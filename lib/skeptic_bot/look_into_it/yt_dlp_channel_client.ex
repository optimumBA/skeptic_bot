defmodule SkepticBot.LookIntoIt.YtDlpChannelClient do
  @moduledoc """
  Getting channel data using yt-dlp
  """
  alias SkepticBot.LookIntoIt.ChannelClient

  require Logger

  @behaviour ChannelClient

  @channel "https://rokfin.com/eddiebravo"

  @impl ChannelClient
  def get_channel_data do
    case System.cmd(
           "yt-dlp",
           [
             "--print",
             "%(title)s$$%(duration)s$$%(thumbnail)s$$%(webpage_url)s$$%(url)s",
             @channel
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
end
