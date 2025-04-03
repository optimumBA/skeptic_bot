defmodule SkepticBot.Podcasts.EpisodeTranscription do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "podcast_episode_transcriptions" do
    field :embedding, Pgvector.Ecto.Vector
    belongs_to :podcast_episode, SkepticBot.Podcasts.Episode
    field :timestamp, EctoInterval
    field :transcription, :string

    timestamps(type: :utc_datetime)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(podcast_episode_transcription, attrs) do
    podcast_episode_transcription
    |> cast(attrs, [:embedding, :podcast_episode_id, :timestamp, :transcription])
    |> validate_required([:podcast_episode_id, :timestamp, :transcription])
    |> unique_constraint([:podcast_episode_id, :timestamp],
      name: :podcast_episode_transcriptions_podcast_episode_id_timestamp_ind
    )
  end
end
