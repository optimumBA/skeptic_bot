defmodule SkepticBot.LookIntoIt.Scraper do
  @moduledoc """
  Scrapes all Eddie Bravo episodes from Rofkin and downloads them
  """

  require Logger

  alias SkepticBot.Podcasts
  alias SkepticBot.LookIntoIt.DownloadingWorker

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
      {result, 0} ->
        result
        |> String.split("\n")
        |> Enum.map(fn x ->
          x
          |> String.split("$$")
          |> List.to_tuple()
        end)
        |> Enum.drop(-1)
        |> Enum.map(&maybe_download_episode/1)

      {error, 1} ->
        Logger.error("Unable to get channel data. Reason : #{error}")
        {:error, error}
    end
  end

  defp maybe_download_episode({title, duration, thumbnail, webpage_url, video_url}) do
    unless Podcasts.episode_exists?(webpage_url) do
      {:ok, %Podcasts.Episode{} = episode} =
        Podcasts.create_episode(%{
          "episode_length" => get_video_length(duration),
          "external_id" => webpage_url,
          "thumbnail" => thumbnail,
          "title" => title
        })

      DownloadingWorker.enqueue(%{
        "id" => episode.id,
        "video_url" => video_url
      })
    end
  end

  defp get_video_length(duration) do
    duration
    |> String.to_float()
    |> round()
  end
end
