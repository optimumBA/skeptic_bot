defmodule SkepticBot.Rag.Generator do
  @moduledoc false

  alias SkepticBot.Rag.ReplicateGenerator

  @type messages :: [LangChain.Message.t()]
  @type reason :: String.t()
  @type response :: String.t()

  @callback predict(messages()) :: {:ok, response()} | {:error, reason()}

  @spec predict(messages()) :: {:ok, response()} | {:error, reason()}
  def predict(messages), do: impl().predict(messages)

  defp impl, do: Application.get_env(:skeptic_bot, :generator, ReplicateGenerator)
end
