defmodule SkepticBot.Rag.RetrievalTest do
  use SkepticBot.DataCase, async: true

  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Rag.Retrieval

  describe "retrieve/1" do
    test "returns episodes with transcription embeddings and builds context" do
      # Create episode with embedding
      episode_embedding = List.duplicate(0.1, 1024)
      episode = episode_fixture(embedding: episode_embedding)

      # Create transcription with embedding
      transcription_embedding = List.duplicate(0.15, 1024)

      _transcription =
        transcription_fixture(%{
          podcast_episode_id: episode.id,
          embedding: transcription_embedding,
          transcription: "Transcription with embedding",
          secs: 0
        })

      # Retrieve with query embedding
      query_embedding = List.duplicate(0.12, 1024)
      results = Retrieval.retrieve(query_embedding)

      # Should return the episode with transcription context
      assert length(results) == 1
      assert hd(results).title == episode.title
      assert hd(results).transcription =~ "Transcription with embedding"
      assert hd(results).timestamp
    end

    test "returns episodes even without transcription embeddings" do
      # Create episode with embedding
      episode_embedding = List.duplicate(0.1, 1024)
      episode = episode_fixture(embedding: episode_embedding)

      # Create transcription WITHOUT embedding
      _transcription =
        transcription_fixture(%{
          podcast_episode_id: episode.id,
          embedding: nil,
          transcription: "Transcription without embedding",
          secs: 0
        })

      # Retrieve with query embedding
      query_embedding = List.duplicate(0.12, 1024)
      results = Retrieval.retrieve(query_embedding)

      # Should still return the episode, but without specific timestamp
      assert length(results) == 1
      assert hd(results).title == episode.title
      assert hd(results).transcription
      refute hd(results).timestamp
    end

    test "returns episodes even without any transcriptions" do
      # Create episode with embedding but NO transcriptions
      episode_embedding = List.duplicate(0.1, 1024)

      episode =
        episode_fixture(%{
          embedding: episode_embedding,
          description: "No transcriptions at all"
        })

      # Retrieve with query embedding
      query_embedding = List.duplicate(0.12, 1024)
      results = Retrieval.retrieve(query_embedding)

      # Should still return the episode with basic info
      assert length(results) == 1
      assert hd(results).title == episode.title
      assert hd(results).description == "No transcriptions at all"
      # Should use description as fallback
      assert hd(results).transcription == hd(results).description
      refute hd(results).timestamp
    end

    test "handles mix of episodes with and without transcription embeddings" do
      # Create first episode with embedded transcription
      episode1 =
        episode_fixture(%{
          title: "Episode with embeddings",
          embedding: List.duplicate(0.1, 1024)
        })

      # Create second episode without transcriptions
      _episode2 =
        episode_fixture(%{
          title: "Episode without transcriptions",
          embedding: List.duplicate(0.11, 1024)
        })

      # Add transcription with embedding to first episode
      _transcription =
        transcription_fixture(%{
          podcast_episode_id: episode1.id,
          embedding: List.duplicate(0.15, 1024),
          transcription: "Embedded transcription",
          secs: 300
        })

      # Retrieve with query embedding
      query_embedding = List.duplicate(0.12, 1024)
      results = Retrieval.retrieve(query_embedding)

      # Should return both episodes
      assert length(results) == 2

      # First episode should have transcription and timestamp
      episode_with_trans = Enum.find(results, &(&1.title == "Episode with embeddings"))
      assert episode_with_trans.transcription =~ "Embedded transcription"
      assert episode_with_trans.timestamp
      assert episode_with_trans.timestamp.secs == 300

      # Second episode should still be returned but without timestamp
      episode_without_trans = Enum.find(results, &(&1.title == "Episode without transcriptions"))
      assert episode_without_trans
      refute episode_without_trans.timestamp
    end

    test "returns empty list when no episodes match distance threshold" do
      # Create an episode with very different embedding
      episode_embedding = List.duplicate(0.9, 1024)
      _episode = episode_fixture(embedding: episode_embedding)

      # Try to retrieve with a very different query embedding
      query_embedding = List.duplicate(0.01, 1024)
      results = Retrieval.retrieve(query_embedding)

      # Should return empty list as episode is outside threshold
      assert results == []
    end

    test "selects most relevant transcription when episode has multiple embedded transcriptions" do
      # Create an episode
      episode_embedding = List.duplicate(0.1, 1024)
      episode = episode_fixture(embedding: episode_embedding)

      # Create multiple transcriptions with different embeddings
      _far_trans =
        transcription_fixture(%{
          podcast_episode_id: episode.id,
          embedding: List.duplicate(0.3, 1024),
          transcription: "Far transcription",
          secs: 100
        })

      _closest_trans =
        transcription_fixture(%{
          podcast_episode_id: episode.id,
          embedding: List.duplicate(0.13, 1024),
          transcription: "Closest transcription",
          secs: 200
        })

      _medium_trans =
        transcription_fixture(%{
          podcast_episode_id: episode.id,
          embedding: List.duplicate(0.2, 1024),
          transcription: "Medium transcription",
          secs: 300
        })

      # Retrieve with query embedding closest to 0.13
      query_embedding = List.duplicate(0.12, 1024)
      results = Retrieval.retrieve(query_embedding)

      # Should return the episode with the closest transcription
      assert length(results) == 1
      result = hd(results)
      assert result.transcription =~ "Closest transcription"
      assert result.timestamp.secs == 200
    end

    test "preserves order by distance when returning multiple episodes" do
      # Create episodes with increasing distance embeddings (but all within threshold)
      _closest =
        episode_fixture(%{
          title: "Closest Episode",
          embedding: List.duplicate(0.11, 1024)
        })

      _middle =
        episode_fixture(%{
          title: "Middle Episode",
          embedding: List.duplicate(0.12, 1024)
        })

      _farthest =
        episode_fixture(%{
          title: "Farthest Episode",
          embedding: List.duplicate(0.13, 1024)
        })

      # Retrieve with query embedding
      query_embedding = List.duplicate(0.11, 1024)
      results = Retrieval.retrieve(query_embedding)

      # All episodes should be returned in order of distance
      assert length(results) == 3
      assert Enum.at(results, 0).title == "Closest Episode"
      assert Enum.at(results, 1).title == "Middle Episode"
      assert Enum.at(results, 2).title == "Farthest Episode"
    end

    test "handles episode with mix of embedded and non-embedded transcriptions" do
      # Create an episode
      episode_embedding = List.duplicate(0.1, 1024)
      episode = episode_fixture(embedding: episode_embedding)

      # Create transcription WITHOUT embedding at timestamp 100
      _non_embedded_before =
        transcription_fixture(%{
          podcast_episode_id: episode.id,
          embedding: nil,
          transcription: "Non-embedded before",
          secs: 100
        })

      # Create transcription WITH embedding at timestamp 200
      _embedded =
        transcription_fixture(%{
          podcast_episode_id: episode.id,
          embedding: List.duplicate(0.15, 1024),
          transcription: "Embedded transcription",
          secs: 200
        })

      # Create transcription WITHOUT embedding at timestamp 300
      _non_embedded_after =
        transcription_fixture(%{
          podcast_episode_id: episode.id,
          embedding: nil,
          transcription: "Non-embedded after",
          secs: 300
        })

      # Retrieve
      query_embedding = List.duplicate(0.12, 1024)
      results = Retrieval.retrieve(query_embedding)

      # Should return episode with the embedded transcription and surrounding context
      assert length(results) == 1
      result = hd(results)

      # Should use the embedded transcription
      assert result.transcription =~ "Embedded transcription"
      assert result.timestamp.secs == 200

      # Should include surrounding non-embedded transcriptions in context
      assert result.transcription =~ "Non-embedded before"
      assert result.transcription =~ "Non-embedded after"
    end

    test "prioritizes episodes with embedded transcriptions in results" do
      # Create multiple episodes with similar embeddings
      _episode_a =
        episode_fixture(%{
          title: "Episode A",
          embedding: List.duplicate(0.1, 1024)
        })

      episode_b =
        episode_fixture(%{
          title: "Episode B",
          embedding: List.duplicate(0.11, 1024)
        })

      _episode_c =
        episode_fixture(%{
          title: "Episode C",
          embedding: List.duplicate(0.12, 1024)
        })

      # Add transcription with embedding only to Episode B
      _transcription =
        transcription_fixture(%{
          podcast_episode_id: episode_b.id,
          embedding: List.duplicate(0.13, 1024),
          transcription: "Transcription for B",
          secs: 100
        })

      # Retrieve
      query_embedding = List.duplicate(0.12, 1024)
      results = Retrieval.retrieve(query_embedding)

      # All episodes should be returned
      assert length(results) == 3

      # Episode B should have transcription context
      episode_b_result = Enum.find(results, &(&1.title == "Episode B"))
      assert episode_b_result.transcription =~ "Transcription for B"
      assert episode_b_result.timestamp.secs == 100

      # Other episodes should still be present
      assert Enum.find(results, &(&1.title == "Episode A"))
      assert Enum.find(results, &(&1.title == "Episode C"))
    end
  end
end
