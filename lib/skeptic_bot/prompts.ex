defmodule SkepticBot.Prompts do
  @moduledoc """
  The context for our prompt
  """
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBot.Rag
  alias SkepticBot.Repo

  @callback get_question_episodes([question_episode()]) :: [episode()]

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
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

  @spec create_question([episode()], String.t(), String.t(), question()) ::
          {:ok, question()} | {:error, changeset()}
  def create_question(list_of_episodes, query, description, question) do
    episode_details =
      Enum.reduce(list_of_episodes, [], fn episode, list ->
        [%{episode_id: episode.id, timestamp: episode.timestamp} | list]
      end)

    embedding_value = query <> " " <> description
    {:ok, [embedding]} = get_rag_embedding_module().generate(embedding_value)

    question_params = %{
      query: query,
      description: description,
      episodes: episode_details,
      embedding: embedding
    }

    question
    |> change_question(question_params)
    |> Repo.insert()
  end

  @spec change_prompt_question(question(), attrs()) :: changeset()
  def change_prompt_question(%UserQuestion{} = question, attrs \\ %{}) do
    UserQuestion.question_changeset(question, attrs)
  end

  @spec change_question(question(), attrs()) :: changeset()
  def change_question(%UserQuestion{} = question, attrs \\ %{}) do
    UserQuestion.changeset(question, attrs)
  end

  defp get_rag_embedding_module do
    Application.get_env(:skeptic_bot, :rag_embedding_module, Rag.Embedding)
  end
end
