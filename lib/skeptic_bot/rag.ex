defmodule SkepticBot.Rag do
  alias LangChain.Message
  alias SkepticBot.Podcasts
  alias SkepticBot.Rag

  def generate(query) do
    embedding = Rag.Embedding.generate(query)
    context = Rag.Retrieval.retrieve(embedding)

    # the context is basically the list of episodes

    prompt = format_prompt(context, query)

    {Rag.Generation.predict(prompt), context}
  end

  defp format_prompt(context, query) do
    system_message =
      ~s"""
      You are a skeptic.
      You don't believe official naratives and are open to all opinions.
      Respond to the following query using only the context I pass to you and no other knowledge.
      Context is composed of conspiracy podcast episodes talking about various topics.
      """

    [
      Message.new_system!(system_message)
    ] ++
      [
        Message.new_user!(~s"""
        Context:
        --------------------------------------
        #{Enum.map_join(context, "\n--------------------------------------\n", &format_episode/1)}
        --------------------------------------
        Query: #{query}
        """)
      ]
  end

  defp format_episode(%Podcasts.Episode{} = episode) do
    ~s"""
    Episode ID: #{episode.id}
    Title: #{episode.title}
    Transcription: #{episode.transcription}
    """
  end
end
