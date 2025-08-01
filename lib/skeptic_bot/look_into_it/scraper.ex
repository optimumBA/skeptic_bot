defmodule SkepticBot.LookIntoIt.Scraper do
  @moduledoc """
  Scrapes all Eddie Bravo episodes from Rofkin
  """

  require Logger

  @type reason :: String.t()

  @channel "https://rokfin.com/eddiebravo"

  @spec scrape :: {:error, reason()} | list()
  def scrape do
    case System.cmd(
           "yt-dlp_macos",
           [
             "--flat-playlist",
             "--print",
             #  "url",
             "%(title)s$$%(url)s",
             @channel
           ],
           env: [],
           stderr_to_stdout: true
         ) do
      {video_urls, 0} ->
        urls =
          video_urls
          |> String.split("\n")
          |> Enum.map(fn x ->
            x
            |> String.split("$$")
            |> List.to_tuple()
          end)

        urls

      {error, 1} ->
        Logger.error("Unable to get channel data. Reason : #{error}")
        {:error, error}
    end
  end
end
