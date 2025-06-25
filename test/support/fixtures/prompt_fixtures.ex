defmodule SkepticBot.PromptFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SkepticBot.Prompts` context.
  """

  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.UserQuestion

  @type description :: String.t()
  @type episode :: Episode.t()
  @type question :: UserQuestion.t()

  @doc """
  create a question.
  """

  @spec question_fixture(map()) :: question()
  def question_fixture(attrs \\ %{}) do
    episode_details =
      5
      |> create_multiple_episodes()
      |> Prompts.get_episode_details()

    question_attrs =
      Enum.into(attrs, %{
        description: description_fixture(),
        embedding: Enum.map(1..1024, fn _some_random_float -> :rand.uniform() end),
        episodes: episode_details,
        query: "American Ponzi with Lee Camp"
      })

    {:ok, question} =
      Prompts.create_question(question_attrs)

    question
  end

  @doc """
  create a description.
  """
  @spec description_fixture :: description()
  def description_fixture do
    random_string =
      12
      |> :crypto.strong_rand_bytes()
      |> Base.encode64()

    "A random description #{random_string}"
  end

  @doc """
  creates multiple episodes.
  """
  @spec create_multiple_episodes(integer()) :: list(episode())
  def create_multiple_episodes(number_of_episodes) do
    for episode <- 1..number_of_episodes do
      episode =
        episode_fixture(%{
          thumbnail: "cover#{episode}.svg",
          title: "episode #{episode} is great",
          description: "a random description #{episode}"
        })

      Map.put(episode, :timestamp, %{secs: :rand.uniform(3000), months: 0, days: 0})
    end
  end
end
