defmodule SkepticBot.Prompt.Episode do
  use Ecto.Schema
  import Ecto.Changeset

  embedded_schema do
    field(:episode_id, :string)
  end

  @doc false
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:episode_id])
    |> validate_required([:episode_id])
  end
end
