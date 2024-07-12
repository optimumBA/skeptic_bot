defmodule SkepticBot.Transcription do
  def serving do
    repo = Application.get_env(:skeptic_bot, :transcription)[:repo]

    {:ok, model_info} = Bumblebee.load_model(repo)
    {:ok, featurizer} = Bumblebee.load_featurizer(repo)
    {:ok, tokenizer} = Bumblebee.load_tokenizer(repo)
    {:ok, generation_config} = Bumblebee.load_generation_config(repo)
    generation_config = Bumblebee.configure(generation_config, max_new_tokens: 100)
    batch_size = Application.get_env(:skeptic_bot, :transcription)[:batch_size]

    Bumblebee.Audio.speech_to_text_whisper(model_info, featurizer, tokenizer, generation_config,
      compile: [batch_size: batch_size],
      chunk_num_seconds: 30,
      timestamps: :segments,
      stream: true,
      defn_options: [compiler: EXLA]
    )
  end

  def transcribe(audio_file) do
    Nx.Serving.batched_run(__MODULE__, {:file, audio_file})
  end
end
