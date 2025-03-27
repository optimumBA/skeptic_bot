defmodule SkepticBot.Prompt do
  @moduledoc """
  The context for our prompt
  """
  alias SkepticBot.Prompt.Question
  alias SkepticBot.Repo
  def get_question!(id), do: Repo.get!(Question, id)

  def change_prompt_question(%Question{} = question, attrs \\ %{}) do
    Question.question_changeset(question, attrs)
  end

  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
  end
end
