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

  @doc """
  Gets a podcast_episode.

  ## Examples

      iex> get_episode(existing_id)
      %Podcasts.Episode{}

      iex> get_episode(non_existing_id)
      nil

  """
  def get_episode(id), do: Repo.get(Episode, id)

  @doc """
  Gets all transcriptions for an episode.

  ## Examples

      iex> get_episode_transcriptions(episode_id)
      {:ok, episode_transcriptions}

  """
  def get_episode_transcriptions(episode_id) do
    transformation = fn ->
      EpisodeTranscription
      |> where([et], et.podcast_episode_id == ^episode_id)
      |> order_by([et], asc: et.timestamp)
      |> Repo.stream()
      |> Stream.map(& &1.transcription)
      |> Enum.join("\n")
    end

    Repo.transaction(transformation, timeout: :infinity)
  end

  @doc """
  Updates a podcast_episode.

  ## Examples

      iex> {:ok, episode} = Podcasts.create_episode()
      ...>
      ...> result =
      ...>   Podcasts.update_episode(episode, %{
      ...>     transcription: "updated transcription"
      ...>   })
      ...>
      ...> with {:ok, %Podcasts.Episode{}} <- result, do: :ok
      :ok

  """
  def update_episode(%Episode{} = episode, attrs) do
    episode
    |> Episode.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Updates a podcast_episode_transcription.

  ## Examples

      iex> {:ok, episode_transcription} = Podcasts.create_episode_transcription()
      ...>
      ...> result =
      ...>   Podcasts.update_episode_transcription(episode_transcription, %{
      ...>     transcription: "updated transcription"
      ...>   })
      ...>
      ...> with {:ok, %Podcasts.EpisodeTranscription{}} <- result, do: :ok
      :ok

  """
  def update_episode_transcription(%EpisodeTranscription{} = episode_transcription, attrs) do
    episode_transcription
    |> EpisodeTranscription.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Processes episode transcriptions in chunks.

  ## Examples

      iex> Podcasts.while_streaming_episode_transcriptions(
      ...>   episode_id,
      ...>   10,
      ...>   fn episode_transcriptions ->
      ...>     IO.inspect(episode_transcriptions)
      ...>   end
      ...> )
      :ok

  """
  def while_streaming_episode_transcriptions(episode_id, chunk_size, callback_fun) do
    transformation = fn ->
      EpisodeTranscription
      |> where([et], et.podcast_episode_id == ^episode_id)
      |> Repo.stream()
      |> Stream.chunk_every(chunk_size)
      |> Stream.each(&callback_fun.(&1))
      |> Stream.run()
    end

    Repo.transaction(transformation, timeout: :infinity)
  end
end
