defmodule SkepticBot.Rag.Generator do
  @moduledoc false

  alias SkepticBot.Rag.ReplicateGenerator

  @type messages :: [LangChain.Message.t()]
  @type output_mode :: atom()
  @type reason :: String.t()
  @type response :: String.t()

  @callback predict(messages(), output_mode()) :: {:ok, response()} | {:error, reason()}

  @spec predict(messages(), output_mode()) :: {:ok, response()} | {:error, reason()}
  def predict(messages, output_mode \\ :processing_and_completed),
    do: impl().predict(messages, output_mode)

  defp impl, do: Application.get_env(:skeptic_bot, :generator, ReplicateGenerator)
end
