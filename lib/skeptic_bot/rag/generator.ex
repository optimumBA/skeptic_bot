defmodule SkepticBot.Rag.Generator do
  @moduledoc false

  alias SkepticBot.Rag.ReplicateGenerator

  @type message :: [LangChain.Message.t()]
  @type reason :: String.t()
  @type response :: String.t()

  @callback predict(message()) :: {:ok, response()} | {:error, reason()}

  @spec predict(message()) :: {:ok, response()} | {:error, reason()}
  def predict(messages), do: impl().predict(messages)

  defp impl, do: Application.get_env(:skeptic_bot, :generator, ReplicateGenerator)
end
