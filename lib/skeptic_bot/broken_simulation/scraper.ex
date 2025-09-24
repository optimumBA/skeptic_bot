defmodule SkepticBot.BrokenSimulation.Scraper do
  @moduledoc """
  Scrapes Broken Simulation episodes from YouTube then downloads them
  """

  alias SkepticBot.Podcasts
  alias SkepticBot.YtDlp.ChannelClient
  alias SkepticBot.YtDlp.EpisodeProcessor
  alias SkepticBot.YtDlp.Helpers

  require Logger

  @channel "https://www.youtube.com/@SamTripoli/streams"
  @podcast "Broken Simulation"

  @type channel :: String.t()
  @type podcast :: Podcasts.Podcast.t()

  @spec scrape :: :ok
  def scrape do
    date = Helpers.get_yesterday_date()
    ChannelClient.get_channel_data_from_port(date, @channel)
    podcast = Podcasts.get_podcast_by_name(@podcast)
    check_for_new_episodes(@channel, podcast)
  end

  @spec check_for_new_episodes(channel(), podcast()) :: :ok
  def check_for_new_episodes(channel, podcast) do
    receive do
      {_port, {:data, msg}} ->
        msg
        |> format_message()
        |> process_episode(channel, podcast)

        check_for_new_episodes(channel, podcast)

      {:close_port, port} ->
        Logger.info("Closed the port")

        case Port.info(port) do
          nil ->
            :ok

          _port_info ->
            Port.close(port)
            :ok
        end
    end
  end

  defp process_episode(
         {<<"Broken Sim", _remainder_title::binary>>, _duration, _thumbnail, _webpage_url} =
           episode,
         channel,
         podcast
       ) do
    EpisodeProcessor.maybe_download_episode(episode, channel, podcast)
    :ok
  end

  defp process_episode(_episode, _channel, _podcast) do
    :ok
  end

  defp format_message(msg) do
    msg
    |> String.trim("\n")
    |> String.split("~~")
    |> List.to_tuple()
  end
end
