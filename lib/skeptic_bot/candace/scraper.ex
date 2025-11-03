defmodule SkepticBot.Candace.Scraper do
  @moduledoc """
  Scrapes Candace Owens' episodes from YouTube then downloads them
  """

  import SkepticBot.YtDlp.Helpers

  alias SkepticBot.Podcasts
  alias SkepticBot.YtDlp.ChannelClient

  @candace_channel_one "https://www.youtube.com/@RealCandaceO/streams"
  @candace_channel_two "https://www.youtube.com/@RealCandaceO/videos"
  @podcast "Candace"

  @spec scrape :: :ok
  def scrape do
    date = get_yesterday_date()
    ChannelClient.get_channel_data_from_port(date, @candace_channel_one)
    ChannelClient.get_channel_data_from_port(date, @candace_channel_two)
    podcast = Podcasts.get_podcast_by_name(@podcast)
    wait_for_episodes(@candace_channel_one, podcast)
    wait_for_episodes(@candace_channel_two, podcast)
  end
end
