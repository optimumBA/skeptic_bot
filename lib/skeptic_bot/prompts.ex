defmodule SkepticBot.Prompts do
  @moduledoc """
  The context for our prompt
  """
  import Ecto.Query
  import Pgvector.Ecto.Query, only: [l2_distance: 2]

  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBot.Repo

  @callback get_other_podcast_episodes(embedding()) :: [episode()]
  @callback get_question_episodes([question_episode()]) :: [episode()]
  @callback get_related_questions(embedding(), id()) :: [question()]

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type embedding :: [float()]
  @type episode :: map()
  @type id :: Ecto.UUID.t()
  @type question :: UserQuestion.t()
  @type question_episode :: map()

  @spec get_question!(id()) :: question() | nil
  def get_question!(id), do: Repo.get!(UserQuestion, id)

  @spec get_question_episodes([question_episode()]) :: [episode()]
  def get_question_episodes(question_episodes) do
    Enum.reduce(question_episodes, [], fn episode, list_of_episodes ->
      episode =
        Episode
        |> Repo.get!(episode.episode_id)
        |> Map.put(:timestamp, episode.timestamp)

      [episode | list_of_episodes]
    end)
  end

  @spec get_related_questions(embedding(), id()) :: [question()]
  def get_related_questions(embedding, id) do
    UserQuestion
    |> select([uq], %{
      id: uq.id,
      description: uq.description,
      query: uq.query
    })
    |> where([uq], uq.id != ^id)
    |> where([uq], fragment("? <-> ? >= ?", uq.embedding, ^embedding, 0.55555))
    |> order_by([uq], asc: l2_distance(uq.embedding, ^embedding))
    |> limit(6)
    |> Repo.all()
  end

  @spec get_other_podcast_episodes(embedding()) :: [episode()]
  def get_other_podcast_episodes(embedding) do
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
          {:ok, question()} | {:error, changeset()}
  def create_question(attrs) do
    %UserQuestion{}
    |> UserQuestion.changeset(attrs)
    |> Repo.insert()
  end

  @spec change_prompt_question(question(), attrs()) :: changeset()
  def change_prompt_question(%UserQuestion{} = question, attrs \\ %{}) do
    UserQuestion.question_changeset(question, attrs)
  end

  @spec get_episode_details([episode()]) :: [episode()]
  def get_episode_details(list_of_episodes) do
    Enum.reduce(list_of_episodes, [], fn episode, list ->
      [%{episode_id: episode.id, timestamp: episode.timestamp} | list]
    end)
  end
end
