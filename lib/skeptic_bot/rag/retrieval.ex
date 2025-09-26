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
  @num_transcriptions_surrounding_the_target 600

  @spec retrieve(embedding()) :: [episode()]
  def retrieve(embedding) do
    embedding
    |> find_relevant_episodes()
    |> Repo.all()
    |> Stream.map(&find_most_relevant_transcription(&1, embedding))
    |> Stream.map(&build_episode_with_context(&1, embedding))
    |> Enum.to_list()
  end

  defp find_relevant_episodes(embedding) do
    from(e in Podcasts.Episode,
      select: e,
      where: fragment("? <-> ? <= ?", e.embedding, ^embedding, @episode_threshold),
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

  defp build_episode_with_context({episode, nil}, _embedding) do
    episode
    |> Map.put(:timestamp, nil)
    |> Map.put(:transcription, get_fallback_transcription(episode))
  end

  defp build_episode_with_context({episode, most_relevant_transcription}, _embedding) do
    transcriptions_before = get_transcriptions_before(episode, most_relevant_transcription)
    transcriptions_after = get_transcriptions_after(episode, most_relevant_transcription)

    transcription =
      "#{transcriptions_before}\n#{most_relevant_transcription.transcription}\n#{transcriptions_after}"

    episode
    |> Map.put(:timestamp, most_relevant_transcription.timestamp)
    |> Map.put(:transcription, transcription)
  end

  defp get_fallback_transcription(episode) do
    # Try to get any transcription without embedding, or use description
    transcriptions_query =
      from(et in Podcasts.EpisodeTranscription,
        select: %{transcription: et.transcription},
        where: et.podcast_episode_id == ^episode.id,
        order_by: [asc: et.timestamp],
        limit: @num_transcriptions_surrounding_the_target
      )

    case Repo.all(transcriptions_query) do
      [] ->
        episode.summary || ""

      transcriptions ->
        Enum.map_join(transcriptions, "\n", & &1.transcription)
    end
  end

  defp get_transcriptions_before(episode, target_transcription) do
    from(et in Podcasts.EpisodeTranscription,
      select: %{transcription: et.transcription},
      where: et.podcast_episode_id == ^episode.id,
      where: et.timestamp < ^target_transcription.timestamp,
      order_by: [desc: et.timestamp],
      limit: @num_transcriptions_surrounding_the_target / 2
    )
    |> Repo.all()
    |> Enum.reverse()
    |> Enum.map_join("\n", & &1.transcription)
  end

  defp get_transcriptions_after(episode, target_transcription) do
    from(et in Podcasts.EpisodeTranscription,
      select: %{transcription: et.transcription},
      where: et.podcast_episode_id == ^episode.id,
      where: et.timestamp > ^target_transcription.timestamp,
      order_by: [asc: et.timestamp],
      limit: @num_transcriptions_surrounding_the_target / 2
    )
    |> Repo.all()
    |> Enum.map_join("\n", & &1.transcription)
  end
end
