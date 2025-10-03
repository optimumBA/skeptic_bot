defmodule SkepticBot.Podcasts.Episode do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "podcast_episodes" do
    field :embedding, Pgvector.Ecto.Vector
    field :episode_length, :integer
    field :external_id, :string
    belongs_to :podcast, SkepticBot.Podcasts.Podcast
    field :summary, :string
    field :teaser, :string
    field :thumbnail, :string
    field :timestamp, EctoInterval, virtual: true
    field :title, :string
    field :transcription, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [
      :embedding,
      :episode_length,
      :external_id,
      :podcast_id,
      :summary,
      :teaser,
      :thumbnail,
      :title
    ])
    |> validate_required([:episode_length, :external_id, :podcast_id, :thumbnail, :title])
    |> unique_constraint(:external_id)
  end
end
