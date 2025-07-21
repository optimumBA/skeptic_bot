defmodule SkepticBot.Prompts do
  @moduledoc """
  The Prompts context.
  """

  import Ecto.Query
  import Pgvector.Ecto.Query, only: [l2_distance: 2]

  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Prompts.PodcastEpisode
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBot.Repo

  @episode_threshold 0.688
  @max_question_distance_threshold 0.60
  @min_question_distance_threshold 0.55
  @vector_offset 0.58

  @type attrs :: map()
  @type embedding :: [float()]
  @type episode :: Episode.t()
  @type episode_details :: map()
  @type id :: Ecto.UUID.t()
  @type prompts_episode :: PodcastEpisode.t()
  @type question :: UserQuestion.t()

  @spec get_question(id()) :: question() | nil
  def get_question(id), do: Repo.get(UserQuestion, id)

  @spec create_question(attrs()) ::
          {:ok, question()} | {:error, Ecto.Changeset.t()}
  def create_question(attrs \\ %{}) do
    %UserQuestion{}
    |> UserQuestion.changeset(attrs)
    |> Repo.insert()
  end

  @spec change_question_query(question(), attrs()) :: Ecto.Changeset.t()
  def change_question_query(%UserQuestion{} = question, attrs \\ %{}) do
    UserQuestion.query_changeset(question, attrs)
  end

  @spec get_episode_details([episode()]) :: [episode_details()]
  def get_episode_details(podcast_episodes) do
    Enum.map(podcast_episodes, fn podcast_episode ->
      %{episode_id: podcast_episode.id, timestamp: podcast_episode.timestamp}
    end)
  end

  @spec get_related_episodes([prompts_episode()], embedding(), integer()) ::
          [episode()]
  def get_related_episodes(question_episodes, question_embedding, limit) do
    question_episodes_timestamps =
      question_episodes
      |> Enum.map(&{&1.episode_id, &1.timestamp})
      |> Enum.into(%{})

    Episode
    |> where([e], fragment("? <-> ? <= ?", e.embedding, ^question_embedding, @episode_threshold))
    |> order_by([e], asc: l2_distance(e.embedding, ^question_embedding))
    |> limit(^limit)
    |> Repo.all()
    |> Enum.map(fn episode ->
      timestamp = question_episodes_timestamps[episode.id]
      Map.put(episode, :timestamp, timestamp)
    end)
  end

  @spec get_other_episodes(embedding(), integer()) :: [episode()]
  def get_other_episodes(question_embedding, limit) do
    Episode
    |> order_by([e], desc: l2_distance(e.embedding, ^question_embedding))
    |> limit(^limit)
    |> Repo.all()
  end

  @spec get_related_questions(embedding(), id()) :: [question()]
  def get_related_questions(question_embedding, question_id) do
    UserQuestion
    |> where([uq], uq.id != ^question_id)
    |> where(
      [uq],
      fragment(
        "? <-> ? >= ?",
        uq.embedding,
        ^question_embedding,
        @min_question_distance_threshold
      )
    )
    |> where(
      [uq],
      fragment(
        "? <-> ? <= ?",
        uq.embedding,
        ^question_embedding,
        @max_question_distance_threshold
      )
    )
    |> order_by([uq], asc: l2_distance(uq.embedding, ^question_embedding))
    |> limit(6)
    |> Repo.all()
  end

  @spec offset_embedding(embedding()) :: embedding()
  def offset_embedding(embedding) do
    vector = Enum.at(embedding, 1023)
    new_vector = vector - @vector_offset
    List.replace_at(embedding, 1023, new_vector)
  end
end
