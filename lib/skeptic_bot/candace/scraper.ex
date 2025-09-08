defmodule SkepticBot.Candace.Scraper do
  @moduledoc """
  Scrapes Candace Owens' episodes from YouTube then downloads them
  """

  alias SkepticBot.Podcasts
  alias SkepticBot.YtDlp.ChannelClient
  alias SkepticBot.YtDlp.EpisodeProcessor

  require Logger

  @channel "https://www.youtube.com/@RealCandaceO/streams"
  @podcast "Candace"

  @type duration :: String.t()
  @type episode :: {title(), duration(), thumbnail(), webpage_url()}
  @type thumbnail :: String.t()
  @type title :: String.t()
  @type webpage_url :: String.t()

  @spec scrape :: :ok
  def scrape do
    date = get_yesterday_date()
    cookie_file = get_cookie_file()
    ChannelClient.get_channel_data_from_port(date, cookie_file, @channel)
    podcast = Podcasts.get_podcast_by_name(@podcast)
    wait_for_episodes(podcast)
  end

  defp process_episode(episode, podcast) do
    EpisodeProcessor.maybe_download_episode(episode, @channel, podcast)
    :ok
  end

  defp wait_for_episodes(podcast) do
    receive do
      {_port, {:data, msg}} ->
        msg
        |> format_message()
        |> process_episode(podcast)

        wait_for_episodes(podcast)

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

  defp format_message(msg) do
    msg
    |> String.trim("\n")
    |> String.split("~~")
    |> List.to_tuple()
  end

  defp get_cookie_file do
    Application.get_env(:skeptic_bot, :youtube_cookie_file_path)
  end

  defp get_yesterday_date do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.add(-1, :day)
    |> Calendar.strftime("%Y%m%d")
  end
end
