defmodule SkepticBot.BrokenSimulation.ScraperTest do
  use SkepticBot.DataCase, async: true

  import ExUnit.CaptureLog
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
        "Broken Simulation Kelly Beef 24~~2500~~https://i.ytimg.com/vi/3CHfault.jpg~~https://www.youtube.com/watch?v=3CHHx4pkBIi"

      port = Port.open({:spawn, "echo #{msg}"}, [:binary])

      msg_2 =
        "Broken Simulation Kirk Ep 25~~2500~~https://i.ytimg.com/vi/3CHfault.jpg~~https://www.youtube.com/watch?v=3CHHx4pkBI4"

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

    test "does not enqueue a downloading job if it receives an invalid episode from yt-dlp" do
      _podcast = podcast_fixture(name: @podcast)

      msg =
        "Cash Daddies Beef 24~~2500~~https://i.ytimg.com/vi/3CHfault.jpg~~https://www.youtube.com/watch?v=3CHHx4pkBIi"

      port = Port.open({:spawn, "echo #{msg}"}, [:binary])

      Process.send_after(self(), {:close_port, port}, 100)

      expect(MockChannelClient, :get_channel_data_from_port, fn _date, _channel ->
        port
      end)

      Scraper.scrape()

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: @podcast,
          video_url: @video_url
        }
      )
    end

    test "logs an error message if yt-dlp scraping from the port returns an error or warning" do
      _podcast = podcast_fixture(name: @podcast)

      msg =
        "Warning! Please sign in to confirm your age."

      port = Port.open({:spawn, "echo #{msg}"}, [:binary])

      Process.send_after(self(), {:close_port, port}, 100)

      expect(MockChannelClient, :get_channel_data_from_port, fn _date, _channel ->
        port
      end)

      log =
        capture_log(fn ->
          Scraper.scrape()
        end)

      assert log =~
               "The episode for the channel: https://www.youtube.com/@SamTripoli/videos in podcast: Broken Simulation failed to download. Reason: Warning! Please sign in to confirm your age."
    end
  end
end
