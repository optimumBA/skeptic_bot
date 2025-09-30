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
    embedding
    |> find_relevant_episodes()
    |> Repo.all()
    |> Stream.map(&find_most_relevant_transcription(&1, embedding))
    |> Stream.map(&add_timestamp(&1))
    |> Enum.to_list()
  end

  defp find_relevant_episodes(embedding) do
    from(e in Podcasts.Episode,
      select: e,
      where: fragment("? <-> ? <= ?", e.embedding, ^embedding, @episode_threshold),
      where: not is_nil(e.summary),
      order_by: [asc: l2_distance(e.embedding, ^embedding)],
      limit: 6
    )
  end

  defp find_most_relevant_transcription(%Podcasts.Episode{} = episode, embedding) do
    most_relevant_transcription =
      Podcasts.EpisodeTranscription
      |> where([et], et.podcast_episode_id == ^episode.id)
      |> where([et], not is_nil(et.embedding))
      |> order_by([et], asc: l2_distance(et.embedding, ^embedding))
      |> limit(1)
      |> Repo.one()

    {episode, most_relevant_transcription}
  end

  defp add_timestamp({episode, nil}), do: Map.put(episode, :timestamp, nil)

  defp add_timestamp({episode, most_relevant_transcription}),
    do: Map.put(episode, :timestamp, most_relevant_transcription.timestamp)
end
