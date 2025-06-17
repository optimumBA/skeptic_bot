defmodule SkepticBot.Rag.Generator do
  @moduledoc false

  alias SkepticBot.Rag.ReqGenerator

  @callback predict([LangChain.Message.t()]) :: {:ok, response()} | {:error, any()}

  @type response :: String.t()

  @spec predict([LangChain.Message.t()]) :: {:ok, response()} | {:error, any()}
  def predict(messages), do: impl().predict(messages)

  defp impl, do: Application.get_env(:skeptic_bot, :generator, ReqGenerator)
end
