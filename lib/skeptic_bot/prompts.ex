defmodule SkepticBot.Prompts do
  @moduledoc """
  The Prompts context.
  """

  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBot.Repo

  @type attrs :: map()
  @type embedding :: [float()]
  @type episode :: Episode.t()
  @type episode_details :: map()
  @type id :: Ecto.UUID.t()
  @type prompts_episode :: SkepticBot.Prompts.Episode.t()
  @type question :: UserQuestion.t()

  @spec get_question(id()) :: question() | nil
  def get_question(id), do: Repo.get(UserQuestion, id)

  @spec get_question_episodes([prompts_episode()]) :: [episode()]
  def get_question_episodes(question_episodes) do
    Enum.reduce(question_episodes, [], fn episode, podcast_episodes ->
      episode =
        Episode
        |> Repo.get!(episode.episode_id)
        |> Map.put(:timestamp, episode.timestamp)

      [episode | podcast_episodes]
    end)
  end

  @spec create_question(attrs()) ::
          {:ok, question()} | {:error, Ecto.Changeset.t()}
  def create_question(attrs \\ %{}) do
    %UserQuestion{}
    |> UserQuestion.changeset(attrs)
    |> Repo.insert()
  end

  @spec change_prompt_question(question(), attrs()) :: Ecto.Changeset.t()
  def change_prompt_question(%UserQuestion{} = question, attrs \\ %{}) do
    UserQuestion.question_changeset(question, attrs)
  end

  @spec get_episode_details([episode()]) :: [episode_details()]
  def get_episode_details(podcast_episodes) do
    Enum.reduce(podcast_episodes, [], fn podcast_episode, question_episodes ->
      [
        %{episode_id: podcast_episode.id, timestamp: podcast_episode.timestamp}
        | question_episodes
      ]
    end)
  end
end
