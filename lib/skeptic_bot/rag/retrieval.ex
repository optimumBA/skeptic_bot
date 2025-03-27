defmodule SkepticBot.Rag.Retrieval do
  import Ecto.Query
  import Pgvector.Ecto.Query, only: [l2_distance: 2]

  alias SkepticBot.Podcasts
  alias SkepticBot.Repo
  require Logger

  @num_transcriptions_surrounding_the_target 100

  def retrieve(embedding) do
    # each podcast episode has an embedding
    # we use that embedding to get a maximum of 3 episodes
    episodes =
      from(e in Podcasts.Episode,
        select: e,
        order_by: [asc: l2_distance(e.embedding, ^embedding)],
        limit: 3
      )
      |> Repo.all()

    # the transcription field for each episode is always going to be nil because that field is virtual

    episodes
    |> Enum.map(fn %Podcasts.Episode{} = episode ->
      most_relevant_transcription =
        from(et in Podcasts.EpisodeTranscription,
          where: et.podcast_episode_id == ^episode.id,
          order_by: [asc: l2_distance(et.embedding, ^embedding)],
          limit: 1
        )
        |> Repo.one()

      transcriptions_before =
        from(et in Podcasts.EpisodeTranscription,
          select: %{transcription: et.transcription},
          where: et.podcast_episode_id == ^episode.id,
          where: et.timestamp < ^most_relevant_transcription.timestamp,
          order_by: [desc: et.timestamp],
          limit: @num_transcriptions_surrounding_the_target / 2
        )
        |> Repo.all()

      transcription =
        transcriptions_before |> Enum.reverse() |> Enum.map_join("\n", & &1.transcription)

      transcription = transcription <> "\n" <> most_relevant_transcription.transcription <> "\n"

      transcriptions_after =
        from(et in Podcasts.EpisodeTranscription,
          select: %{transcription: et.transcription},
          where: et.podcast_episode_id == ^episode.id,
          where: et.timestamp > ^most_relevant_transcription.timestamp,
          order_by: [asc: et.timestamp],
          limit: @num_transcriptions_surrounding_the_target / 2
        )
        |> Repo.all()

      transcription =
        transcription <> Enum.map_join(transcriptions_after, "\n", & &1.transcription)

      Map.put(episode, :transcription, transcription)
    end)
  end
end
