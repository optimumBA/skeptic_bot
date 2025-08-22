defmodule SkepticBot.PodcastsTest do
  use SkepticBot.DataCase, async: true

  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Podcasts.EpisodeTranscription

  @invalid_episode_attrs %{external_id: nil, title: nil}
  @valid_episode_attrs %{
    description: "Sample description",
    episode_length: 4000,
    external_id: "test-123",
    thumbnail: "/static/thumbnail.png",
    title: "Test Episode"
  }
  @invalid_episode_transcription_attrs %{
    timestamp: %{secs: 44.900, months: 0, days: 0},
    transcription: nil
  }
  @valid_episode_transcription_attrs %{
    timestamp: %{secs: :rand.uniform(3000), months: 0, days: 0},
    transcription: "Sample episode transcription"
  }

  defp create_episode(_attrs) do
    episode = episode_fixture()
    %{episode: episode}
  end

  describe "create_episode/1" do
    test "with valid data creates an episode" do
      podcast = podcast_fixture()
      attrs = Map.put(@valid_episode_attrs, :podcast_id, podcast.id)

      assert {:ok, %Episode{} = episode} = Podcasts.create_episode(attrs)
      assert episode.description == "Sample description"
      assert episode.title == "Test Episode"
      assert episode.external_id == "test-123"
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Podcasts.create_episode(@invalid_episode_attrs)
    end
  end

  describe "get_episode/1" do
    setup [:create_episode]

    test "returns the episode with given id", %{episode: episode} do
      assert Podcasts.get_episode(episode.id) == episode
    end

    test "returns nil for non-existent id" do
      refute Podcasts.get_episode("14444444-edaa-444a-a333-7a77758ad305")
    end
  end

  describe "get_episode_by_external_id/1" do
    test "returns the episode with given external_id" do
      episode = episode_fixture(external_id: "c8aa9b82-03e1-417e-b4ad-7ce380c25414")
      assert Podcasts.get_episode_by_external_id(episode.external_id) == episode
    end

    test "returns nil for non-existent external_id" do
      refute Podcasts.get_episode_by_external_id("14444444-edaa-444a-a333-7a77758ad305")
    end
  end

  describe "episode_exists?/1" do
    setup [:create_episode]

    test "returns true for existing episode", %{episode: episode} do
      assert Podcasts.episode_exists?(episode.external_id)
    end

    test "returns false for non-existent episode" do
      refute Podcasts.episode_exists?("14444444-edaa-444a-a333-7a77758ad305")
    end
  end

  describe "update_episode/2" do
    setup [:create_episode]

    test "with valid data updates an episode", %{episode: episode} do
      update_attrs = %{description: "a new description", title: "updated title"}

      assert {:ok, %Episode{} = updated_episode} = Podcasts.update_episode(episode, update_attrs)
      assert updated_episode.title == "updated title"
      assert updated_episode.description == "a new description"
    end

    test "with invalid data returns error changeset", %{episode: episode} do
      assert {:error, %Ecto.Changeset{}} =
               Podcasts.update_episode(episode, @invalid_episode_attrs)
    end
  end

  describe "create_episode_transcription/1" do
    setup [:create_episode]

    test "with valid data creates a transcription", %{
      episode: episode
    } do
      attrs = Map.put(@valid_episode_transcription_attrs, :podcast_episode_id, episode.id)

      assert {:ok, %EpisodeTranscription{} = episode_transcription} =
               Podcasts.create_episode_transcription(attrs)

      assert episode_transcription.podcast_episode_id == episode.id
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} =
               Podcasts.create_episode_transcription(@invalid_episode_transcription_attrs)
    end
  end

  describe "update_episode_transcription/2" do
    setup [:create_episode]

    setup %{episode: episode} do
      transcription = transcription_fixture(%{podcast_episode_id: episode.id})
      %{transcription: transcription}
    end

    test "with valid data updates the transcription", %{
      transcription: transcription
    } do
      update_attrs = %{transcription: "Updated transcription"}

      assert {:ok, %EpisodeTranscription{} = updated_transcription} =
               Podcasts.update_episode_transcription(transcription, update_attrs)

      assert updated_transcription.transcription == "Updated transcription"
    end

    test "with invalid data returns error changeset", %{
      transcription: transcription
    } do
      assert {:error, %Ecto.Changeset{}} =
               Podcasts.update_episode_transcription(
                 transcription,
                 @invalid_episode_transcription_attrs
               )
    end
  end

  describe "get_episode_transcriptions/1" do
    setup [:create_episode]

    test "returns concatenated transcriptions", %{episode: episode} do
      transcription_attrs = [
        %{
          transcription: "First part",
          timestamp: %{secs: 10, months: 0, days: 0},
          podcast_episode_id: episode.id
        },
        %{
          transcription: "Second part",
          timestamp: %{secs: 20, months: 0, days: 0},
          podcast_episode_id: episode.id
        }
      ]

      Enum.each(transcription_attrs, fn attrs ->
        {:ok, _episode_transcription} = Podcasts.create_episode_transcription(attrs)
      end)

      assert {:ok, result} = Podcasts.get_episode_transcriptions(episode.id)
      assert result == "First part\nSecond part"
    end
  end

  describe "while_streaming_episode_transcriptions/3" do
    setup [:create_episode]

    test "processes transcriptions in chunks", %{
      episode: episode
    } do
      transcription_attrs = [
        %{
          podcast_episode_id: episode.id,
          timestamp: %{secs: 10, months: 0, days: 0},
          transcription: "Transcription 1"
        },
        %{
          podcast_episode_id: episode.id,
          timestamp: %{secs: 20, months: 0, days: 0},
          transcription: "Transcription 2"
        },
        %{
          podcast_episode_id: episode.id,
          timestamp: %{secs: 30, months: 0, days: 0},
          transcription: "Transcription 3"
        },
        %{
          podcast_episode_id: episode.id,
          timestamp: %{secs: 40, months: 0, days: 0},
          transcription: "Transcription 4"
        },
        %{
          podcast_episode_id: episode.id,
          timestamp: %{secs: 60, months: 0, days: 0},
          transcription: "Transcription 5"
        }
      ]

      Enum.each(transcription_attrs, fn attrs ->
        {:ok, _episode_transcription} = Podcasts.create_episode_transcription(attrs)
      end)

      Process.put(:processed_chunks, [])

      callback = fn chunk ->
        Process.put(:processed_chunks, [chunk | Process.get(:processed_chunks)])
        :ok
      end

      assert {:ok, _count} =
               Podcasts.while_streaming_episode_transcriptions(episode.id, 2, callback)

      processed_chunks = Process.get(:processed_chunks)

      assert length(processed_chunks) == 3
      [chunk_1, chunk_2, chunk_3] = processed_chunks
      assert length(chunk_1) == 1
      assert length(chunk_2) == 2
      assert length(chunk_3) == 2
    end
  end
end
