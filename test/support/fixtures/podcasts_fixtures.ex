defmodule SkepticBot.PodcastsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `SkepticBot.Podcasts` context.
  """

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Podcasts.EpisodeTranscription

  @type embedding :: [float()]

  defp generate_id do
    12
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
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
        external_id: generate_id(),
        embedding: Enum.map(1..1024, fn _some_random_float -> :rand.uniform() end)
      })
      |> Podcasts.create_episode()

    episode
  end

  @doc """
  create an embedding.
  """
  @spec embedding_fixture :: embedding()
  def embedding_fixture do
    Enum.map(1..1024, fn _some_random_float -> :rand.uniform() end)
  end

  @spec body_fixture :: map()
  def body_fixture do
    %{
      "data" => [
        %{
          "description" => "Is this a suitable description?",
          "name" => "Cash Daddies 2",
          "uuid" => "a909da70-13b7-4717-b1c0-c2d001521dc3"
        }
      ]
    }
  end

  @spec chunks_fixture :: list()
  def chunks_fixture do
    [
      %{
        "text" => "Welcome to the episode!",
        "timestamp" => [0.0, 5.5]
      },
      %{
        "text" => "  We talk about functional programming.",
        "timestamp" => [5.5, 15.2]
      },
      %{
        "text" => "Thanks for listening!   ",
        "timestamp" => [nil, 20.0]
      }
    ]
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
