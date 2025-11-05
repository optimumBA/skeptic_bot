defmodule SkepticBot.Candace.Scraper do
  @moduledoc """
  Scrapes Candace Owens' episodes from YouTube then downloads them
  """

  import SkepticBot.YtDlp.Helpers

  alias SkepticBot.Podcasts
  alias SkepticBot.YtDlp.ChannelClient

  @channel "https://www.youtube.com/@RealCandaceO/streams"
  @podcast "Candace"

  @spec scrape :: :ok
  def scrape do
    date = get_yesterday_date()
    ChannelClient.get_channel_data_from_port(date, @channel)
    podcast = Podcasts.get_podcast_by_name(@podcast)
    wait_for_episodes(@channel, podcast)
  end
end
