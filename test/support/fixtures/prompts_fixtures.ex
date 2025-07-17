defmodule SkepticBot.PromptsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SkepticBot.Prompts` context.
  """

  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.UserQuestion

  @type embedding :: [float()] | nil
  @type episode :: Episode.t()
  @type question :: UserQuestion.t()

  @doc """
  creates a question.
  """

  @spec question_fixture(map()) :: question()
  def question_fixture(attrs \\ %{}) do
    embedding = embedding_fixture()

    question_attrs =
      Enum.into(attrs, %{
        description: "A simple description",
        embedding: embedding,
        query: "American Ponzi with Lee Camp and Sam Tripoli"
      })

    {:ok, question} =
      Prompts.create_question(question_attrs)

    question
  end

  @doc """
  creates multiple episodes.
  """
  @spec create_multiple_episodes(integer(), embedding()) :: list(episode())
  def create_multiple_episodes(number_of_episodes, embedding \\ nil) do
    for episode <- 1..number_of_episodes do
      episode =
        episode_fixture(%{
          description: "a random description #{episode}",
          thumbnail: "cover#{episode}.svg",
          title: "Consistency truly is key to mastering any skill over time and effort.",
          embedding: embedding
        })

      Map.put(episode, :timestamp, %{secs: :rand.uniform(3000), months: 0, days: 0})
    end
  end
end
