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

  @type attrs :: map()
  @type embedding :: [float()]
  @type episode :: Episode.t()
  @type episode_details :: map()
  @type id :: Ecto.UUID.t()
  @type prompts_episode :: PodcastEpisode.t()
  @type question :: UserQuestion.t()

  @spec get_question(id()) :: question() | nil
  def get_question(id), do: Repo.get(UserQuestion, id)

  @spec get_related_episodes([prompts_episode()]) :: [episode()]
  def get_related_episodes(question_episodes) do
    {question_episodes_ids, question_episodes_timestamps} =
      Enum.reduce(question_episodes, {[], %{}}, fn episode, {ids, timestamps} ->
        {[episode.episode_id | ids], Map.put(timestamps, episode.episode_id, episode.timestamp)}
      end)

    Episode
    |> where([e], e.id in ^question_episodes_ids)
    |> Repo.all()
    |> Enum.map(fn episode ->
      timestamp = question_episodes_timestamps[episode.id]
      %{episode | timestamp: timestamp}
    end)
  end

  @spec get_other_episodes(embedding()) :: [episode()]
  def get_other_episodes(embedding) do
    Episode
    |> select([e], %{
      episode_length: e.episode_length,
      title: e.title,
      external_id: e.external_id,
      thumbnail: e.thumbnail
    })
    |> order_by([e], desc: l2_distance(e.embedding, ^embedding))
    |> limit(3)
    |> Repo.all()
  end

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
end
