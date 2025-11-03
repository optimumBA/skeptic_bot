defmodule SkepticBot.NephilimDeathSquad.Scraper do
  @moduledoc """
  Scrapes Nephilim Death Squad episodes from YouTube then downloads them
  """

  import SkepticBot.YtDlp.Helpers

  alias SkepticBot.Podcasts
  alias SkepticBot.YtDlp.ChannelClient

  @nephilimdeathsquad_channel_one "https://www.youtube.com/@NephilimDeathSquad/streams"
  @nephilimdeathsquad_channel_two "https://www.youtube.com/@NephilimDeathSquad/videos"
  @podcast "Nephilim Death Squad"

  @spec scrape :: :ok
  def scrape do
    date = get_yesterday_date()
    ChannelClient.get_channel_data_from_port(date, @nephilimdeathsquad_channel_one)
    ChannelClient.get_channel_data_from_port(date, @nephilimdeathsquad_channel_two)
    podcast = Podcasts.get_podcast_by_name(@podcast)
    wait_for_episodes(@nephilimdeathsquad_channel_one, podcast)
    wait_for_episodes(@nephilimdeathsquad_channel_two, podcast)
  end
end
