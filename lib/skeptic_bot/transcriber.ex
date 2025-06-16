defmodule SkepticBot.Transcriber do
  @moduledoc false

  alias SkepticBot.ReplicateTranscriber

  @type audio_url :: String.t()

  @callback transcribe(audio_url()) :: {:ok, list()} | {:error, any()}

  @spec transcribe(audio_url()) :: {:ok, list()} | {:error, any()}
  def transcribe(audio_url), do: impl().transcribe(audio_url)

  defp impl, do: Application.get_env(:skeptic_bot, :transcriber, ReplicateTranscriber)
end
