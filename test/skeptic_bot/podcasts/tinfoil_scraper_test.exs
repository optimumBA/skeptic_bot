defmodule SkepticBot.Podcasts.TinfoilScraperTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.TinfoilScraperFixtures
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.MockHttpClient
  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DownloadingWorker
  alias SkepticBot.Podcasts.TinfoilScraper

  @external_id "a909da70-13b7-4717-b1c0-c2d001521dc3"

  defp create_scraper_resources(_attrs) do
    body = body_fixture()

    %{body: body}
  end

  describe "scrape/1" do
    setup [:create_scraper_resources]

    test "enqueues a job if episode does not already exist",
         %{body: body} do
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

      assert Podcasts.episode_exists?(@external_id)

      assert_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end

    test "does not enqueue a job if episode already exists", %{body: body} do
      _episode = episode_fixture(external_id: "a909da70-13b7-4717-b1c0-c2d001521dc3")

      expect(MockHttpClient, :make_request, 1, fn _url ->
        {:ok, %Req.Response{status: 200, body: body}}
      end)

      expect(MockHttpClient, :make_request, 1, fn _url ->
        {:ok,
         %Req.Response{
           status: 200,
           body: %{
             "data" => []
           }
         }}
      end)

      TinfoilScraper.scrape()

      assert Podcasts.episode_exists?(@external_id)

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end

    test "does not download an episode if there are no episodes in the return data" do
      expect(MockHttpClient, :make_request, 1, fn _url ->
        {:ok,
         %Req.Response{
           status: 200,
           body: %{
             "data" => []
           }
         }}
      end)

      refute Podcasts.episode_exists?(@external_id)

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end

    test "does not insert a job when HTTP request is unsuccessful" do
      expect(MockHttpClient, :make_request, 1, fn _url ->
        {:error, "Could not make request"}
      end)

      TinfoilScraper.scrape()

      refute Podcasts.episode_exists?(@external_id)

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end
  end

  describe "scrape_episode/2" do
    setup [:create_scraper_resources]

    test "returns an episode not found error if there are no episodes in the return data" do
      expect(MockHttpClient, :make_request, 1, fn _url ->
        {:ok,
         %Req.Response{
           status: 200,
           body: %{
             "data" => []
           }
         }}
      end)

      assert TinfoilScraper.scrape_episode("a909da70-13b7-4717-b1c0-c2d001521dc3") ==
               {:error, :episode_not_found}

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end

    test "downloads the episode if it finds it in the returned body", %{body: body} do
      expect(MockHttpClient, :make_request, 1, fn _url ->
        {:ok,
         %Req.Response{
           status: 200,
           body: body
         }}
      end)

      TinfoilScraper.scrape_episode("a909da70-13b7-4717-b1c0-c2d001521dc3")

      assert Podcasts.episode_exists?(@external_id)

      assert_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end

    test "does not insert a job when HTTP request is unsuccessful" do
      expect(MockHttpClient, :make_request, 1, fn _url ->
        {:error, "Could not make request"}
      end)

      TinfoilScraper.scrape_episode("a909da70-13b7-4717-b1c0-c2d001521dc3")

      refute Podcasts.episode_exists?(@external_id)

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end

    test "does not enqueue a job if it doesn't find it in the body", %{body: body} do
      expect(MockHttpClient, :make_request, 1, fn _url ->
        {:ok,
         %Req.Response{
           status: 200,
           body: body
         }}
      end)

      expect(MockHttpClient, :make_request, 1, fn _url ->
        {:error, "Could not make request"}
      end)

      TinfoilScraper.scrape_episode("a909da70-13b7-4717-b1c0-c2d001521ec3")

      refute Podcasts.episode_exists?(@external_id)

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{external_id: @external_id}
      )
    end
  end
end
