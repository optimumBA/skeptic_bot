defmodule SkepticBot.LookIntoIt.ScraperTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.PodcastsFixtures
  import SkepticBot.ScrapingFixtures

  alias SkepticBot.LookIntoIt.MockChannelClient
  alias SkepticBot.LookIntoIt.Scraper
  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DownloadingWorker

  @video_url "https://rkfn-media.global.ssl.fastly.net/jGrM0w/v.mp4"
  @rokfin_channel "https://rokfin.com/eddiebravo"
  @rumble_channel "https://rumble.com/c/eddiebravo/videos?e9s=src_v1_sa%2Csrc_v1_sa_o"
  @external_id "177589-jGrM0w"
  @podcast "Look Into It"

  setup :verify_on_exit!

  defp get_channel_data(_attrs) do
    channel_data = rokfin_channel_fixture()
    %{channel_data: channel_data}
  end

  describe "scrape/1" do
    setup [:get_channel_data]

    test "enqueues a downloading job if episode does not already exist for Rokfin", %{
      channel_data: channel_data
    } do
      refute Podcasts.episode_exists?(@external_id)

      expect(MockChannelClient, :get_channel_data, fn _channel ->
        {:ok, channel_data}
      end)

      Scraper.scrape(@rokfin_channel)

      assert_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: @podcast,
          video_url: @video_url
        }
      )
    end

    test "enqueues a downloading job if episode does not already exist for Rumble" do
      channel_data = rumble_channel_fixture()

      refute Podcasts.episode_exists?(@external_id)

      expect(MockChannelClient, :get_channel_data, fn _channel ->
        {:ok, channel_data}
      end)

      Scraper.scrape(@rumble_channel)

      assert_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: @podcast,
          video_url: @video_url
        }
      )
    end

    test "does not enqueue a downloading job if episode already exists", %{
      channel_data: channel_data
    } do
      _episode = episode_fixture(external_id: @external_id)

      expect(MockChannelClient, :get_channel_data, fn _channel ->
        {:ok, channel_data}
      end)

      Scraper.scrape(@rokfin_channel)

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: @podcast,
          video_url: @video_url
        }
      )
    end

    test "does not enqueue a downloading job if there are no episodes in the return data" do
      expect(MockChannelClient, :get_channel_data, fn _channel ->
        {:ok, ""}
      end)

      Scraper.scrape(@rokfin_channel)

      refute_enqueued(worker: DownloadingWorker)
    end

    @tag :capture_log
    test "does not enqueue a downloading job if the yt-dlp request is unsuccessful" do
      expect(MockChannelClient, :get_channel_data, fn _channel ->
        {:error, "Too many retries"}
      end)

      Scraper.scrape(@rokfin_channel)

      refute_enqueued(worker: DownloadingWorker)
    end
  end
end
