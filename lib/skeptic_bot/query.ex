defmodule SkepticBot.Query do
  @moduledoc """
  The context for our prompt
  """
  alias SkepticBot.Prompt

  def change_prompt(%Prompt{} = prompt, attrs \\ %{}) do
    Prompt.changeset(prompt, attrs)
  end
end
