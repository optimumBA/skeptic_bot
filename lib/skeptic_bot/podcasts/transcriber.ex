defmodule SkepticBot.Podcasts.Transcriber do
  @moduledoc false

  alias SkepticBot.Podcasts.ReplicateTranscriber

  @type audio_url :: String.t()
  @type chunks :: list()
  @type reason :: String.t()

  @callback transcribe(audio_url()) :: {:ok, chunks()} | {:error, reason()}

  @spec transcribe(audio_url()) :: {:ok, chunks()} | {:error, reason()}
  def transcribe(audio_url), do: impl().transcribe(audio_url)

  defp impl, do: Application.get_env(:skeptic_bot, :transcriber, ReplicateTranscriber)
end
