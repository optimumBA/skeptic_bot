defmodule SkepticBot.Transcription do
  @moduledoc """
  Provides audio transcription capabilities using Replicate's speech recognition models.
  Handles the conversion of audio to text and processes the chunked output.
  """

  alias SkepticBot.ReplicateClient

  require Logger

  @behaviour ReplicateClient

  @callback transcribe(String.t()) :: {:ok, list()} | {:error, any()}

  @model "vaibhavs10/incredibly-fast-whisper:3ab86df6c8f54c11309d4d1f930ac292bad43ace52d10c80d87eb258b3c9f79c"

  @impl ReplicateClient
  def get_type, do: "transcription"

  @impl ReplicateClient
  def handle_output(%{"chunks" => chunks}), do: chunks
  def handle_output(output), do: output

  @spec transcribe(String.t()) :: {:ok, list()} | {:error, any()}
  def transcribe(audio_url) do
    input = %{
      audio: audio_url,
      task: "transcribe",
      language: "None",
      timestamp: "chunk",
      batch_size: 24,
      diarise_audio: false
    }

    ReplicateClient.start_prediction(__MODULE__, @model, input, :timer.minutes(30))
  end
end
