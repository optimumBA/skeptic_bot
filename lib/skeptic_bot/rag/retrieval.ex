defmodule SkepticBot.Rag.Retrieval do
  @moduledoc """
  Handles retrieval of relevant podcast episodes and transcriptions based on vector embeddings.
  Uses vector similarity search to find the most relevant content.
  """

  import Ecto.Query
  import Pgvector.Ecto.Query, only: [l2_distance: 2]

  alias SkepticBot.Podcasts
  alias SkepticBot.Repo

  @type embedding :: [float()]
  @type episode :: map()

  @num_transcriptions_surrounding_the_target 100

  @spec retrieve(embedding()) :: [episode()]
  def retrieve(embedding) do
    from(e in Podcasts.Episode,
      select: e,
      order_by: [asc: l2_distance(e.embedding, ^embedding)],
      limit: 3
    )
    |> Repo.all()
    |> Enum.map(fn %Podcasts.Episode{} = episode ->
      most_relevant_transcription =
        from(et in Podcasts.EpisodeTranscription,
          where: et.podcast_episode_id == ^episode.id,
          order_by: [asc: l2_distance(et.embedding, ^embedding)],
          limit: 1
        )
        |> Repo.one()
        |> Map.get(:transcription)

      transcriptions_before =
        from(et in Podcasts.EpisodeTranscription,
          select: %{transcription: et.transcription},
          where: et.podcast_episode_id == ^episode.id,
          where: et.timestamp < ^most_relevant_transcription.timestamp,
          order_by: [desc: et.timestamp],
          limit: @num_transcriptions_surrounding_the_target / 2
        )
        |> Repo.all()
        |> Enum.reverse()
        |> Enum.map_join("\n", & &1.transcription)

      transcriptions_after =
        from(et in Podcasts.EpisodeTranscription,
          select: %{transcription: et.transcription},
          where: et.podcast_episode_id == ^episode.id,
          where: et.timestamp > ^most_relevant_transcription.timestamp,
          order_by: [asc: et.timestamp],
          limit: @num_transcriptions_surrounding_the_target / 2
        )
        |> Repo.all()
        |> Enum.map_join("\n", & &1.transcription)

      transcription =
        "#{transcriptions_before}\n#{most_relevant_transcription}\n#{transcriptions_after}"

      Map.put(episode, :transcription, transcription)
    end)
  end
end
