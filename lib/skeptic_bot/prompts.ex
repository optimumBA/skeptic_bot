defmodule SkepticBot.Prompts do
  @moduledoc """
  The context for our prompt
  """

  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBot.Repo

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type embedding :: [float()]
  @type episode :: map()
  @type id :: Ecto.UUID.t()
  @type question :: UserQuestion.t()
  @type question_episode :: map()

  @spec get_question(id()) :: question() | nil
  def get_question(id), do: Repo.get(UserQuestion, id)

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
