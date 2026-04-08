defmodule SkepticBot.Podcasts.TinfoilScraperTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.PodcastsFixtures
  import SkepticBot.ScrapingFixtures

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.DownloadingWorker
  alias SkepticBot.Podcasts.MockHttpClient
  alias SkepticBot.Podcasts.TinfoilScraper

  @external_id "a909da70-13b7-4717-b1c0-c2d001521dc3"
  @podcast "Tin Foil Hat"
  @video_url "https://vid.samtripoli.com/w/a909da70-13b7-4717-b1c0-c2d001521dc3"

  setup :verify_on_exit!

  defp empty_response do
    {:ok, %Req.Response{status: 200, body: %{"data" => []}}}
  end

  defp expect_additional_channel_scrapes do
    # scrape_additional_channels/0 scrapes 4 channels: brokensimulation, cashdaddies, doomscrollin, unionoftheunwanted
    expect(MockHttpClient, :make_request, fn _url -> empty_response() end)
    expect(MockHttpClient, :make_request, fn _url -> empty_response() end)
    expect(MockHttpClient, :make_request, fn _url -> empty_response() end)
    expect(MockHttpClient, :make_request, fn _url -> empty_response() end)
  end

  defp create_body(_attrs) do
    body = body_fixture()
    _podcast_2 = podcast_fixture(name: "Doom Scrollin")
    _podcast_3 = podcast_fixture(name: "Cash Daddies")
    _podcast_3 = podcast_fixture(name: "Broken Simulation")
    _podcast_5 = podcast_fixture(name: "Zero with Sam Tripoli")
    _podcast_6 = podcast_fixture(name: "Union of the Unwanted")

    %{body: body}
  end

  describe "get_url/0" do
    test "returns Sam Tripoli url for making api requests" do
      assert "https://vid.samtripoli.com/api/v1/video-channels/tinfoilhat/videos?start=<start>&count=100&sort=-publishedAt&skipCount=false&nsfw=both" ==
               TinfoilScraper.get_url()
    end
  end

  describe "scrape/1" do
    setup [:create_body]

    test "enqueues a downloading job if episode does not already exist", %{body: body} do
      _podcast = podcast_fixture()

      refute Podcasts.episode_exists?(@external_id)

      expect(MockHttpClient, :make_request, fn _url ->
        {:ok, %Req.Response{status: 200, body: body}}
      end)

      expect(MockHttpClient, :make_request, fn _url ->
        {:ok, %Req.Response{status: 200, body: %{"data" => []}}}
      end)

      expect_additional_channel_scrapes()

      TinfoilScraper.scrape()

      assert_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: @podcast,
          video_url: @video_url
        }
      )
    end

    test "does not enqueue a downloading job if episode already exists", %{body: body} do
      _episode = episode_fixture(external_id: @external_id)

      expect(MockHttpClient, :make_request, fn _url ->
        {:ok, %Req.Response{status: 200, body: body}}
      end)

      expect(MockHttpClient, :make_request, fn _url ->
        {:ok, %Req.Response{status: 200, body: %{"data" => []}}}
      end)

      expect_additional_channel_scrapes()

      TinfoilScraper.scrape()

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: @podcast,
          video_url: @video_url
        }
      )
    end

    test "does not enqueue a downloading job if there are no episodes in the return data" do
      expect(MockHttpClient, :make_request, fn _url ->
        {:ok, %Req.Response{status: 200, body: %{"data" => []}}}
      end)

      expect_additional_channel_scrapes()

      TinfoilScraper.scrape()

      refute_enqueued(worker: DownloadingWorker)
    end

    test "does not enqueue a downloading job if the HTTP request is unsuccessful" do
      expect(MockHttpClient, :make_request, fn _url ->
        {:error, "Could not make request"}
      end)

      TinfoilScraper.scrape()

      refute_enqueued(worker: DownloadingWorker)
    end
  end

  describe "scrape_channel/3" do
    @channel_external_id "b101ef71-24c8-5828-c2d1-d3e112632ed4"
    @channel_video_url "https://vid.samtripoli.com/w/b101ef71-24c8-5828-c2d1-d3e112632ed4"

    defp channel_body_fixture do
      %{
        "data" => [
          %{
            "duration" => 1800,
            "name" => "Broken Simulation Episode 1",
            "thumbnailPath" => "/static/thumbnails/abc.jpg",
            "uuid" => @channel_external_id
          }
        ]
      }
    end

    setup do
      _podcast = podcast_fixture(name: "Broken Simulation")
      :ok
    end

    test "enqueues a downloading job for a channel episode that does not already exist" do
      refute Podcasts.episode_exists?(@channel_external_id)

      expect(MockHttpClient, :make_request, fn _url ->
        {:ok, %Req.Response{status: 200, body: channel_body_fixture()}}
      end)

      expect(MockHttpClient, :make_request, fn _url -> empty_response() end)

      TinfoilScraper.scrape_channel("brokensimulation", "Broken Simulation")

      assert_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: "Broken Simulation",
          video_url: @channel_video_url
        }
      )
    end

    test "does not enqueue a downloading job for a channel episode that already exists" do
      _episode = episode_fixture(external_id: @channel_external_id)

      expect(MockHttpClient, :make_request, fn _url ->
        {:ok, %Req.Response{status: 200, body: channel_body_fixture()}}
      end)

      expect(MockHttpClient, :make_request, fn _url -> empty_response() end)

      TinfoilScraper.scrape_channel("brokensimulation", "Broken Simulation")

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: "Broken Simulation",
          video_url: @channel_video_url
        }
      )
    end

    test "does not enqueue a downloading job if there are no episodes in the channel" do
      expect(MockHttpClient, :make_request, fn _url -> empty_response() end)

      TinfoilScraper.scrape_channel("brokensimulation", "Broken Simulation")

      refute_enqueued(worker: DownloadingWorker)
    end

    test "does not enqueue a downloading job if the channel HTTP request is unsuccessful" do
      expect(MockHttpClient, :make_request, fn _url ->
        {:error, "Could not make request"}
      end)

      TinfoilScraper.scrape_channel("brokensimulation", "Broken Simulation")

      refute_enqueued(worker: DownloadingWorker)
    end
  end

  describe "scrape_episode/2" do
    setup [:create_body]

    test "enqueues the episode if it finds it in the returned body", %{body: body} do
      _podcast = podcast_fixture()

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
        args: %{
          podcast: @podcast,
          video_url: @video_url
        }
      )
    end

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
        args: %{
          podcast: @podcast,
          video_url: @video_url
        }
      )
    end

    test "does not enqueue a downloading job if the HTTP request is unsuccessful" do
      expect(MockHttpClient, :make_request, fn _url ->
        {:error, "Could not make request"}
      end)

      TinfoilScraper.scrape_episode(@external_id)

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: @podcast,
          video_url: @video_url
        }
      )
    end

    test "does not enqueue a downloading job if it doesn't find the episode in the body", %{
      body: body
    } do
      expect(MockHttpClient, :make_request, fn _url ->
        {:ok,
         %Req.Response{
           status: 200,
           body: body
         }}
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

      TinfoilScraper.scrape_episode("a909da70-13b7-4717-b1c0-c2d001521ec3")

      refute_enqueued(
        worker: DownloadingWorker,
        args: %{
          podcast: @podcast,
          video_url: @video_url
        }
      )
    end
  end
end
