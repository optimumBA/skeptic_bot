defmodule SkepticBot.PodcastsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SkepticBot.Podcasts` context.
  """

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Podcasts.EpisodeTranscription
  alias SkepticBot.Podcasts.Podcast

  @valid_l2_distance_offset 0.58

  @type embedding :: [float()]
  @type offset :: float()
  @type podcast_name :: String.t()
  @type response :: String.t()

  @doc """
  create an embedding.
  """
  @spec embedding_fixture :: embedding()
  def embedding_fixture do
    Enum.map(1..1024, fn _some_random_float -> :rand.uniform() end)
  end

  @spec offset_embedding_fixture(embedding(), offset()) :: embedding()
  def offset_embedding_fixture(embedding, offset \\ @valid_l2_distance_offset) do
    List.update_at(embedding, -1, &(&1 - offset))
  end

  @doc """
  creates an episode.
  """
  @spec episode_fixture(map(), podcast_name()) :: Episode.t()
  def episode_fixture(attrs \\ %{}, podcast_name \\ "Tin Foil Hat") do
    podcast = podcast_fixture(%{name: podcast_name})

    {:ok, episode} =
      attrs
      |> Enum.into(%{
        episode_length: :rand.uniform(3000),
        external_id: Ecto.UUID.generate(),
        podcast_id: podcast.id,
        thumbnail: "cover1.svg",
        title: "Test Episode",
        summary: "Sample summary"
      })
      |> Podcasts.create_episode()

    episode
  end

  @spec podcast_fixture(map()) :: Podcast.t()
  def podcast_fixture(attrs \\ %{}) do
    {:ok, podcast} =
      attrs
      |> Enum.into(%{
        name: "Tin Foil Hat"
      })
      |> Podcasts.create_podcast()

    podcast
  end

  @doc """
  creates a transcription.
  """
  @spec transcription_fixture(map()) :: EpisodeTranscription.t()
  def transcription_fixture(attrs \\ %{}) do
    {:ok, episode_transcription} =
      attrs
      |> Enum.into(%{
        embedding: attrs[:embedding],
        podcast_episode_id: attrs[:episode_id],
        timestamp: %{secs: attrs[:secs] || :rand.uniform(3000), months: 0, days: 0, microsecs: 0},
        transcription: attrs[:transcription] || "Sample episode transcription"
      })
      |> Podcasts.create_episode_transcription()

    episode_transcription
  end
end
