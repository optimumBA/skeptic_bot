defmodule SkepticBot.Transcription do
  require Logger

  @behaviour SkepticBot.ReplicateClient

  @model "vaibhavs10/incredibly-fast-whisper:3ab86df6c8f54c11309d4d1f930ac292bad43ace52d10c80d87eb258b3c9f79c"

  def get_type, do: "transcription"

  def handle_output(%{"chunks" => chunks}), do: chunks
  def handle_output(output), do: output

  def transcribe(audio_url) do
    input = %{
      audio: audio_url,
      task: "transcribe",
      language: "None",
      timestamp: "chunk",
      batch_size: 64,
      diarise_audio: false
    }

    SkepticBot.ReplicateClient.start_prediction(__MODULE__, @model, input, :timer.minutes(30))
  end
end
