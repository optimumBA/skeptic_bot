defmodule SkepticBot.Prompt.Episode do
  @moduledoc """
  Used as an embedded schema inside a SkepticBot.Prompt.Question schema
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{}

  embedded_schema do
    field :episode_id, :string
  end

  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:episode_id])
    |> validate_required([:episode_id])
  end
end
