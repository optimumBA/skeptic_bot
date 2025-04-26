defmodule SkepticBot.Prompt do
  @moduledoc """
  The context for our prompt
  """
  alias SkepticBot.Prompt.UserQuestion
  alias SkepticBot.Repo

  @type attrs :: map()
  @type changeset :: Ecto.Changeset.t()
  @type question :: UserQuestion.t()
  @type id :: Ecto.UUID.t()

  @spec get_question!(id()) :: question() | nil
  def get_question!(id), do: Repo.get!(UserQuestion, id)

  @spec change_prompt_question(question(), attrs()) :: changeset()
  def change_prompt_question(%UserQuestion{} = question, attrs \\ %{}) do
    UserQuestion.question_changeset(question, attrs)
  end

  @spec change_question(question(), attrs()) :: changeset()
  def change_question(%UserQuestion{} = question, attrs \\ %{}) do
    UserQuestion.changeset(question, attrs)
  end
end
