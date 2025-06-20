defmodule SkepticBot.Podcasts.TinfoilScraperTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.PodcastsFixtures
  import SkepticBot.ScrapingFixtures

  alias SkepticBot.MockHttpClient
  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DownloadingWorker
  alias SkepticBot.Podcasts.TinfoilScraper

  @external_id "a909da70-13b7-4717-b1c0-c2d001521dc3"

  setup :verify_on_exit!

  defp create_scraper_resources(_attrs) do
    body = body_fixture()
    %{body: body}
  end

  describe "scrape/1" do
    setup [:create_scraper_resources]

    test "enqueues a downloading job if episode does not already exist", %{body: body} do
      refute Podcasts.episode_exists?(@external_id)

      expect(MockHttpClient, :make_request, fn _url ->
        {:ok, %Req.Response{status: 200, body: body}}
      end)

      expect(MockHttpClient, :make_request, fn _url ->
        {:ok,
         %Req.Response{
           status: 200,
           body: %{
             "data" => []
           }
         }}
      end)

      TinfoilScraper.scrape()

      assert_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end

    test "does not enqueue a downloading job if episode already exists", %{body: body} do
      _episode = episode_fixture(external_id: @external_id)

      expect(MockHttpClient, :make_request, fn _url ->
        {:ok, %Req.Response{status: 200, body: body}}
      end)

      expect(MockHttpClient, :make_request, fn _url ->
        {:ok,
         %Req.Response{
           status: 200,
           body: %{
             "data" => []
           }
         }}
      end)

      TinfoilScraper.scrape()

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end

    test "does not enqueue a downloading job if there are no episodes in the return data" do
      expect(MockHttpClient, :make_request, fn _url ->
        {:ok,
         %Req.Response{
           status: 200,
           body: %{
             "data" => []
           }
         }}
      end)

      TinfoilScraper.scrape()

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end

    test "does not enqueue a downloading job if the HTTP request is unsuccessful" do
      expect(MockHttpClient, :make_request, fn _url ->
        {:error, "Could not make request"}
      end)

      TinfoilScraper.scrape()

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end
  end

  describe "scrape_episode/2" do
    setup [:create_scraper_resources]

    test "returns an episode_not_found error if there are no episodes in the return data" do
      expect(MockHttpClient, :make_request, fn _url ->
        {:ok,
         %Req.Response{
           status: 200,
           body: %{
             "data" => []
           }
         }}
      end)

      assert {:error, :episode_not_found} ==
               TinfoilScraper.scrape_episode(@external_id)

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end

    test "downloads the episode if it finds it in the returned body", %{body: body} do
      expect(MockHttpClient, :make_request, fn _url ->
        {:ok,
         %Req.Response{
           status: 200,
           body: body
         }}
      end)

      TinfoilScraper.scrape_episode(@external_id)

      assert Podcasts.episode_exists?(@external_id)

      assert_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end

    test "does not insert a job when HTTP request is unsuccessful" do
      expect(MockHttpClient, :make_request, fn _url ->
        {:error, "Could not make request"}
      end)

      TinfoilScraper.scrape_episode(@external_id)

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end

    test "does not enqueue a job if it doesn't find it in the body", %{body: body} do
      expect(MockHttpClient, :make_request, fn _url ->
        {:ok,
         %Req.Response{
           status: 200,
           body: body
         }}
      end)

      expect(MockHttpClient, :make_request, fn _url ->
        {:error, "Could not make request"}
      end)

      TinfoilScraper.scrape_episode("a909da70-13b7-4717-b1c0-c2d001521ec3")

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end
  end
end
