defmodule SkepticBot.Podcasts do
  @moduledoc """
  The Podcasts context.
  """

  import Ecto.Query, warn: false

  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Podcasts.EpisodeTranscription
  alias SkepticBot.Repo

  @doc """
  Creates a podcast_episode.

  ## Examples

      iex> create_episode(%{field: value})
      {:ok, %Episode{}}

      iex> create_episode(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_episode(attrs \\ %{}) do
    %Episode{}
    |> Episode.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Creates a podcast_episode_transcription.

  ## Examples

      iex> create_episode_transcription(%{field: value})
      {:ok, %EpisodeTranscription{}}

      iex> create_episode_transcription(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_episode_transcription(attrs \\ %{}) do
    %EpisodeTranscription{}
    |> EpisodeTranscription.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Checks if a podcast episode exists.

  ## Examples

      iex> exists?(existing_id)
      true

      iex> exists?(non_existing_id)
      false

  """
  def episode_exists?(id),
    do: Repo.exists?(from e in Episode, where: e.external_id == ^id)
end
