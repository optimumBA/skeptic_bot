defmodule SkepticBot.LookIntoIt.Scraper do
  @moduledoc """
  Scrapes all Eddie Bravo episodes from Rofkin
  """
  require Logger

  @channel "https://rokfin.com/eddiebravo"
  # @list "yt-dlp_macos --flat-playlist --print url https://www.rokfin.com/eddiebravo"

  def scrape() do
    case System.cmd(
           "yt-dlp_macos",
           [
             "--flat-playlist",
             "--print",
             "url",
             @channel
           ],
           env: [],
           stderr_to_stdout: true
         ) do
      {video_urls, 0} ->
        video_urls

      {error, 1} ->
        Logger.error("Unable to get channel data. Reason : #{error}")
        {:error, error}
    end
  end
end
