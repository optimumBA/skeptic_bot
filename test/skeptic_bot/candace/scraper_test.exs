defmodule SkepticBot.Candace.ScraperTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Candace.Scraper
  alias SkepticBot.Podcasts.DownloadingWorker
  alias SkepticBot.YtDlp.MockChannelClient

  @podcast "Candace"

  setup :verify_on_exit!

  describe "scrape/0" do
    test "enqueues a downloading job if it receives an episode from yt-dlp" do
      _podcast = podcast_fixture(name: @podcast)

      data =
        "Eminem Drops A Diss Track Ep 24~~2500~~https://i.ytimg.com/vi/3CHfault.jpg~~https://www.youtube.com/watch?v=3CHHx4pkBIo"

      port = Port.open({:spawn, "echo #{data}"}, [:binary])

      Process.send_after(self(), {:close_port, port}, 100)

      expect(MockChannelClient, :get_channel_data_from_port, fn _date, _cookie_file, _channel ->
        port
      end)

      Scraper.scrape()

      assert_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: @podcast,
          video_url: "https://www.youtube.com/watch?v=3CHHx4pkBIo"
        }
      )
    end
  end

  describe "scrape_from_file/0" do
    test "enqueues episodes from the file" do
      _podcast = podcast_fixture(name: @podcast)

      Scraper.scrape_from_file()

      assert_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: @podcast,
          video_url: "https://www.youtube.com/watch?v=3CHHx4pkBIo"
        }
      )
    end
  end
end
