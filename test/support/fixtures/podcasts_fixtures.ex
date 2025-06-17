defmodule SkepticBot.PodcastsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SkepticBot.Podcasts` context.
  """

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Podcasts.EpisodeTranscription

  @type response :: String.t()

  @doc """
  create a response.
  """
  @spec response_fixture :: response()
  def response_fixture do
    random_string =
      12
      |> :crypto.strong_rand_bytes()
      |> Base.encode64()

    "A random response with #{random_string}"
  end

  defp generate_id do
    12
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
  end

  @spec embedding_fixture() :: [float()]
  def embedding_fixture do
    Enum.map(1..1024, fn _some_random_float -> :rand.uniform() end)
  end

  @doc """
  creates an episode.
  """
  @spec episode_fixture(map()) :: Episode.t()
  def episode_fixture(attrs \\ %{}) do
    {:ok, episode} =
      attrs
      |> Enum.into(%{
        title: "Test Episode",
        description: "Sample description",
        episode_length: :rand.uniform(3000),
        external_id: generate_id(),
        thumbnail: "cover1.svg"
      })
      |> Podcasts.create_episode()

    episode
  end

  @doc """
  creates a transcription.
  """
  @spec transcription_fixture(map()) :: EpisodeTranscription.t()
  def transcription_fixture(attrs \\ %{}) do
    {:ok, episode_transcription} =
      attrs
      |> Enum.into(%{
        embedding: Enum.map(1..1024, fn _some_random_float -> :rand.uniform() end),
        timestamp: %{secs: :rand.uniform(3000), months: 0, days: 0},
        transcription: "Sample episode transcription"
      })
      |> Podcasts.create_episode_transcription()

    episode_transcription
  end
end
