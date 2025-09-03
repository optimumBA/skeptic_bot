defmodule SkepticBot.LookIntoIt.Scraper do
  @moduledoc """
  Scrapes Eddie Bravo's episodes from Rokfin and Rumble then downloads them
  """

  alias SkepticBot.Podcasts.ThumbnailDownloader
  alias SkepticBot.LookIntoIt.ChannelClient
  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DownloadingWorker
  alias SkepticBot.Storage.TigrisStorageProvider

  require Logger

  @podcast "Look Into It"
  @rokfin_channel "https://rokfin.com/eddiebravo"
  @rumble_channel "https://rumble.com/c/eddiebravo/videos?e9s=src_v1_sa%2Csrc_v1_sa_o"

  @type channel :: String.t()
  @type reason :: String.t()

  @spec scrape(channel()) :: :ok | {:error, reason()}
  def scrape(channel \\ @rumble_channel) do
    case ChannelClient.get_channel_data(channel) do
      {:ok, result} ->
        podcast = Podcasts.get_podcast_by_name(@podcast)

        result
        |> format_channel_data()
        |> Enum.each(&maybe_download_episode(&1, channel, podcast.id))

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

  defp maybe_download_episode({title, duration, thumbnail, webpage_url}, channel, podcast_id) do
    external_id = get_external_id(webpage_url, channel)

    unless Podcasts.episode_exists?(external_id) do
      {:ok, %Podcasts.Episode{} = episode} =
        Podcasts.create_episode(%{
          "episode_length" => get_video_length(duration, channel),
          "external_id" => external_id,
          "podcast_id" => podcast_id,
          "thumbnail" => thumbnail,
          "title" => title
        })

      DownloadingWorker.enqueue(%{
        "id" => episode.id,
        "podcast" => @podcast,
        "thumbnail" => thumbnail,
        "video_url" => webpage_url
      })
    end
  end

  defp get_video_length(duration, @rokfin_channel) do
    duration
    |> String.to_float()
    |> round()
  end

  defp get_video_length(duration, @rumble_channel) do
    String.to_integer(duration)
  end

  defp get_external_id(webpage_url, @rokfin_channel) do
    <<"https://rokfin.com/post/", webpage_id::binary>> = webpage_url

    webpage_id
  end

  defp get_external_id(webpage_url, @rumble_channel) do
    <<"https://rumble.com/", webpage_id::binary>> = webpage_url

    webpage_id
  end
end
