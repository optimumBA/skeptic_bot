defmodule SkepticBot.Prompts.Episode do
  @moduledoc """
  Used as an embedded schema inside SkepticBot.Prompt.UserQuestion
  """

  use Ecto.Schema

  import Ecto.Changeset

  @type attrs :: map()
  @type t :: %__MODULE__{}

  embedded_schema do
    field :episode_id, :string
    field :timestamp, EctoInterval
  end

  @spec changeset(t(), attrs()) :: Ecto.Changeset.t()
  def changeset(episode, attrs) do
    episode
    |> cast(attrs, [:episode_id, :timestamp])
    |> validate_required([:episode_id, :timestamp])
  end
end
