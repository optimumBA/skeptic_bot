defmodule SkepticBot.BrokenSimulation.ScraperTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.BrokenSimulation.Scraper
  alias SkepticBot.Podcasts.DownloadingWorker
  alias SkepticBot.YtDlp.MockChannelClient

  @podcast "Broken Simulation"
  @video_url "https://www.youtube.com/watch?v=3CHHx4pkBIi"

  setup :verify_on_exit!

  describe "scrape/0" do
    test "enqueues a downloading job if it receives an episode from yt-dlp" do
      _podcast = podcast_fixture(name: @podcast)

      msg =
        "Machine Gun Kelly Beef 24~~2500~~https://i.ytimg.com/vi/3CHfault.jpg~~https://www.youtube.com/watch?v=3CHHx4pkBIi"

      port = Port.open({:spawn, "echo #{msg}"}, [:binary])

      msg_2 =
        "Murder of Charlie Kirk Ep 25~~2500~~https://i.ytimg.com/vi/3CHfault.jpg~~https://www.youtube.com/watch?v=3CHHx4pkBI4"

      send(self(), {port, {:data, msg_2}})

      Process.send_after(self(), {:close_port, port}, 100)

      expect(MockChannelClient, :get_channel_data_from_port, fn _date, _channel ->
        port
      end)

      Scraper.scrape()

      assert_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: @podcast,
          video_url: @video_url
        }
      )

      assert_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: @podcast,
          video_url: "https://www.youtube.com/watch?v=3CHHx4pkBI4"
        }
      )
    end
  end
end
