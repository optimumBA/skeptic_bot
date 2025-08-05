defmodule SkepticBot.LookIntoIt.ScraperTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.PodcastsFixtures
  import SkepticBot.ScrapingFixtures

  alias SkepticBot.LookIntoIt.DownloadingWorker
  alias SkepticBot.LookIntoIt.MockChannelClient
  alias SkepticBot.LookIntoIt.Scraper
  alias SkepticBot.Podcasts

  @video_url "https://rkfn-media.global.ssl.fastly.net/jGrM0w/v.mp4"
  @webpage_url "https://rokfin.com/post/177589"

  setup :verify_on_exit!

  defp get_channel_data(_attrs) do
    channel_data = channel_fixture()
    %{channel_data: channel_data}
  end

  describe "scrape/0" do
    setup [:get_channel_data]

    test "enqueues a downloading job if episode does not already exist", %{
      channel_data: channel_data
    } do
      refute Podcasts.episode_exists?(@webpage_url)

      expect(MockChannelClient, :get_channel_data, fn ->
        {:ok, channel_data}
      end)

      Scraper.scrape()

      assert_enqueued(
        worker: DownloadingWorker,
        args: %{video_url: @video_url}
      )
    end

    test "does not enqueue a downloading job if episode already exists", %{
      channel_data: channel_data
    } do
      _episode = episode_fixture(external_id: @webpage_url)

      expect(MockChannelClient, :get_channel_data, fn ->
        {:ok, channel_data}
      end)

      Scraper.scrape()

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{video_url: @video_url}
      )
    end

    test "does not enqueue a downloading job if there are no episodes in the return data" do
      expect(MockChannelClient, :get_channel_data, fn ->
        {:ok, ""}
      end)

      Scraper.scrape()

      refute_enqueued(worker: DownloadingWorker)
    end

    test "does not enqueue a downloading job if the HTTP request is unsuccessful" do
      expect(MockChannelClient, :get_channel_data, fn ->
        {:error, "Too many retries"}
      end)

      Scraper.scrape()

      refute_enqueued(worker: DownloadingWorker)
    end
  end
end
