defmodule SkepticBot.LookIntoIt.Scraper do
  @moduledoc """
  Scrapes Eddie Bravo episodes from Rofkin and downloads them
  """

  alias SkepticBot.LookIntoIt.ChannelClient
  alias SkepticBot.LookIntoIt.DownloadingWorker
  alias SkepticBot.Podcasts

  require Logger

  @type reason :: String.t()

  @spec scrape :: :ok | {:error, reason()}
  def scrape do
    case ChannelClient.get_channel_data() do
      {:ok, result} ->
        result
        |> format_channel_data()
        |> Enum.each(&maybe_download_episode/1)

      {:error, reason} ->
        Logger.error("Unable to get channel data. Reason : #{reason}")
        {:error, reason}
    end
  end

  defp format_channel_data(result) do
    result
    |> String.split("\n")
    |> Enum.map(fn x ->
      x
      |> String.split("$$")
      |> List.to_tuple()
    end)
    |> Enum.drop(-1)
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
