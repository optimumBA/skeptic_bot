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

  @type episode :: {title(), duration(), thumbnail(), webpage_url()}
  @type duration :: String.t()
  @type thumbnail :: String.t()
  @type title :: String.t()
  @type webpage_url :: String.t()

  @spec scrape :: :ok
  def scrape do
    date = get_yesterday_date()
    cookie_file = get_cookie_file()
    ChannelClient.get_channel_data_from_port(date, cookie_file, @channel)
    wait_for_episodes()
  end

  @spec scrape_from_file :: :ok
  def scrape_from_file do
    episodes = get_episodes()
    Enum.each(episodes, &process_episode/1)
  end

  @spec process_episode(episode()) :: :ok
  defp process_episode(episode) do
    podcast = Podcasts.get_podcast_by_name(@podcast)
    EpisodeProcessor.maybe_download_episode(episode, @channel, podcast)
    :ok
  end

  defp wait_for_episodes do
    receive do
      {_port, {:data, msg}} ->
        msg
        |> format_message()
        |> process_episode()

        wait_for_episodes()

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

  defp get_episodes do
    [:code.priv_dir(:skeptic_bot), "/dumps/candace.txt"]
    |> Path.join()
    |> File.read!()
    |> format_channel_data()
  end

  defp format_message(msg) do
    msg
    |> String.trim("\n")
    |> String.split("~~")
    |> List.to_tuple()
  end

  defp format_channel_data(result) do
    result
    |> String.split("\n")
    |> Enum.map(fn x ->
      x
      |> String.split("~~")
      |> List.to_tuple()
    end)
    |> Enum.drop(-1)
  end

  defp get_cookie_file do
    Path.join([:code.priv_dir(:skeptic_bot), "/cookies/youtube_cookies.txt"])
  end

  defp get_yesterday_date do
    {year, month, day} =
      Date.utc_today()
      |> Date.add(-1)
      |> Date.to_erl()

    "#{pad(year)}#{pad(month)}#{pad(day)}"
  end

  defp pad(value) when value < 10, do: "0#{value}"
  defp pad(value), do: "#{value}"
end
