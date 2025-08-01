defmodule SkepticBot.LookIntoIt.Scraper do
  @moduledoc """
  Scrapes all Eddie Bravo episodes from Rofkin
  """

  require Logger

  alias SkepticBot.Podcasts

  @type reason :: String.t()

  @channel "https://rokfin.com/eddiebravo"

  @spec scrape :: {:error, reason()} | list()
  def scrape do
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
      {video_urls, 0} ->
        urls =
          video_urls
          |> String.split("\n")
          |> Enum.map(fn x ->
            x
            |> String.split("$$")
            |> List.to_tuple()
          end)
          |> List.delete_at(110)

        # ["https://rokfin.com/post/80732"]

        Enum.map(urls, &maybe_download_episode/1)

        urls

      {error, 1} ->
        Logger.error("Unable to get channel data. Reason : #{error}")
        {:error, error}
    end
  end

  defp maybe_download_episode({title, duration, thumbnail, webpage_url, _video_url} = details) do
    unless Podcasts.episode_exists?(webpage_url) do
      {:ok, %Podcasts.Episode{} = episode} =
        Podcasts.create_episode(%{
          "episode_length" => get_video_length(duration),
          "external_id" => webpage_url,
          "thumbnail" => thumbnail,
          "title" => title
        })

      episode
    end
  end

  defp get_video_length(duration) do
    duration
    |> String.to_float()
    |> round()
  end
end
