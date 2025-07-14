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
end
