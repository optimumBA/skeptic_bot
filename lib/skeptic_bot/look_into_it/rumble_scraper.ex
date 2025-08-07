defmodule SkepticBot.LookIntoIt.RumbleScraper do
  @moduledoc """
  Scrapes Eddie Bravo episodes from Rumble and downloads them
  """

  alias SkepticBot.LookIntoIt.ChannelClient
  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DownloadingWorker

  require Logger
  @channel "https://rumble.com/eddiebravo"
  @podcast "Look Into It"

  @type reason :: String.t()

  @spec scrape :: :ok | {:error, reason()}
  def scrape do
    case ChannelClient.get_channel_data(@channel) do
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
          "external_id" => get_external_id(webpage_url, video_url),
          "thumbnail" => thumbnail,
          "title" => title
        })

      DownloadingWorker.enqueue(%{
        "id" => episode.id,
        "podcast" => @podcast,
        "video_url" => video_url
      })
    end
  end

  defp get_video_length(duration) do
    duration
    |> String.to_float()
    |> round()
  end

  defp get_external_id(webpage_url, video_url) do
    <<"https://rokfin.com/post/", webpage_id::binary>> = webpage_url

    <<"https://rkfn-media.global.ssl.fastly.net/", rest::binary>> =
      video_url

    video_id = String.replace_trailing(rest, "/v.mp4", "")

    webpage_id <> "-" <> video_id
  end
end
