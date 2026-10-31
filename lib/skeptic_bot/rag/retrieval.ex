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

  @episode_threshold Application.compile_env!(:skeptic_bot, :related_episode_threshold)

  @spec retrieve(embedding()) :: [episode()]
  def retrieve(embedding) do
    episodes =
      embedding
      |> find_relevant_episodes()
      |> Repo.all()

    transcriptions = find_relevant_transcriptions(episodes, embedding)
    Enum.map(episodes, &add_timestamp({&1, Map.get(transcriptions, &1.id)}))
  end

  defp find_relevant_episodes(embedding) do
    from(e in Podcasts.Episode,
      select: e,
      where: fragment("? <-> ? <= ?", e.embedding, ^embedding, @episode_threshold),
      where: not is_nil(e.summary),
      order_by: [asc: l2_distance(e.embedding, ^embedding), asc: e.id],
      limit: 6
    )
  end

  defp find_relevant_transcriptions([], _embedding), do: %{}

  defp find_relevant_transcriptions(episodes, embedding) do
    episode_ids = Enum.map(episodes, & &1.id)

    from(et in Podcasts.EpisodeTranscription,
      where: et.podcast_episode_id in ^episode_ids and not is_nil(et.embedding),
      distinct: et.podcast_episode_id,
      order_by: [
        asc: et.podcast_episode_id,
        asc: l2_distance(et.embedding, ^embedding),
        asc: et.id
      ]
    )
    |> Repo.all()
    |> Map.new(&{&1.podcast_episode_id, &1})
  end

  defp add_timestamp({episode, nil}), do: Map.put(episode, :timestamp, nil)

  defp add_timestamp({episode, most_relevant_transcription}),
    do: Map.put(episode, :timestamp, most_relevant_transcription.timestamp)
end
