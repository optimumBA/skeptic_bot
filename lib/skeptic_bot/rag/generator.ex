defmodule SkepticBot.Rag.Generator do
  @moduledoc false

  alias SkepticBot.Rag.ReplicateGenerator

  @type reason :: any()
  @type response :: String.t()

  @callback predict([LangChain.Message.t()]) :: {:ok, response()} | {:error, reason()}

  @spec predict([LangChain.Message.t()]) :: {:ok, response()} | {:error, reason()}
  def predict(messages), do: impl().predict(messages)

  defp impl, do: Application.get_env(:skeptic_bot, :generator, ReplicateGenerator)
end
