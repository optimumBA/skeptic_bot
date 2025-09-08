defmodule SkepticBot.LookIntoIt.Scraper do
  @moduledoc """
  Scrapes Eddie Bravo's episodes from Rokfin and Rumble then downloads them
  """

  alias SkepticBot.Podcasts
  alias SkepticBot.YtDlp.ChannelClient
  alias SkepticBot.YtDlp.EpisodeProcessor

  require Logger

  @podcast "Look Into It"
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
        |> Enum.each(&EpisodeProcessor.maybe_download_episode(&1, channel, podcast))

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
end
