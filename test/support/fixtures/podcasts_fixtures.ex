defmodule SkepticBot.PodcastsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SkepticBot.Podcasts` context.
  """

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Podcasts.EpisodeTranscription

  @type embedding :: [float()]

  @doc """
  create an embedding.
  """
  @spec embedding_fixture :: embedding()
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
        description: "Sample description",
        episode_length: :rand.uniform(3000),
        external_id: Ecto.UUID.generate(),
        thumbnail: "cover1.svg",
        title: "Test Episode"
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
        embedding: embedding_fixture(),
        timestamp: %{secs: :rand.uniform(3000), months: 0, days: 0},
        transcription: "Sample episode transcription"
      })
      |> Podcasts.create_episode_transcription()

    episode_transcription
  end
end
