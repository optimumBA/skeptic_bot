defmodule SkepticBot.EpisodesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SkepticBot.Podcasts` context.
  """

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Episode

  @type episode :: Episode.t()
  @type embedding :: [float()]
  @type description :: String.t()

  @doc """
  create an episode.
  """
  @spec episode_fixture(map()) :: episode()
  def episode_fixture(attrs \\ %{}) do
    random_string =
      12
      |> :crypto.strong_rand_bytes()
      |> Base.encode64()

    episode_attrs =
      Enum.into(attrs, %{
        external_id: random_string,
        thumbnail: "cover1.svg",
        title: "Just another episode #{random_string}",
        description: "a random description #{random_string}"
      })

    {:ok, episode} =
      Podcasts.create_episode(episode_attrs)

    Map.put(episode, :timestamp, %{secs: 62, months: 0, days: 0})
  end

  @doc """
  create an embedding.
  """
  @spec embedding_fixture :: embedding()
  def embedding_fixture do
    Enum.map(1..1024, fn _some_random_float -> :rand.uniform() end)
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
end
