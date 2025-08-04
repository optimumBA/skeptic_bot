defmodule SkepticBot.LookIntoIt.YtDlpEpisodeClient do
  @moduledoc """
  Getting channel data using yt-dlp
  """
  alias SkepticBot.LookIntoIt.EpisodeClient

  require Logger

  @behaviour EpisodeClient

  @channel "https://rokfin.com/eddiebravo"

  @impl EpisodeClient
  def get_channel_data do
    case System.cmd(
           "yt-dlp_macos",
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
