defmodule SkepticBot.YtDlp.EpisodeProcessorTest do
  use SkepticBot.DataCase, async: true

  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Podcasts
  alias SkepticBot.YtDlp.EpisodeProcessor

  @broken_simulation_channel "https://www.youtube.com/@SamTripoli/videos"

  describe "maybe_download_episode/3 video length parsing" do
    test "returns an integer episode_length for a valid duration string" do
      podcast = podcast_fixture(name: "Broken Simulation")

      episode = {
        "Broken Simulation Test Episode",
        "3600",
        "https://i.ytimg.com/vi/abc123/default.jpg",
        "https://www.youtube.com/watch?v=abc123"
      }

      EpisodeProcessor.maybe_download_episode(episode, @broken_simulation_channel, podcast)

      created_episode = Podcasts.get_episode_by_external_id("abc123")

      assert created_episode != nil
      assert created_episode.episode_length == 3600
    end

    test "returns 0 when duration is NA" do
      podcast = podcast_fixture(name: "Broken Simulation")

      episode = {
        "Broken Simulation NA Duration Episode",
        "NA",
        "https://i.ytimg.com/vi/xyz789/default.jpg",
        "https://www.youtube.com/watch?v=xyz789"
      }

      EpisodeProcessor.maybe_download_episode(episode, @broken_simulation_channel, podcast)

      created_episode = Podcasts.get_episode_by_external_id("xyz789")

      assert created_episode != nil
      assert created_episode.episode_length == 0
    end
  end
end
