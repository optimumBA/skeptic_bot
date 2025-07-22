defmodule SkepticBot.Rag do
  @moduledoc """
  Implements a Retrieval-Augmented Generation system for podcast content.
  Combines vector search retrieval with language model generation to create contextual responses.
  """

  alias LangChain.Message
  alias SkepticBot.Podcasts
  alias SkepticBot.Rag

  @type embedding :: [float()]

  @spec generate(String.t()) ::
          {:ok, {String.t(), list(), embedding()}}
          | {:error, any()}
  def generate(query) do
    case Rag.Embedder.generate("query: " <> query) do
      {:ok, [embedding]} ->
        case Rag.Retrieval.retrieve(embedding) do
          [] ->
            {:error, :no_episodes_found}

          context ->
            predict_query(context, query, embedding)
        end

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp predict_query(context, query, embedding) do
    with prompt <- format_prompt(context, query),
         {:ok, response} <- Rag.Generator.predict(prompt) do
      {:ok, {String.trim(response), context, embedding}}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp format_prompt(context, query) do
    system_message =
      ~s"""
      You are a skeptic.
      You don't believe official naratives and are open to all opinions.
      Respond to the following query using only the context I pass to you and no other knowledge.
      Context is composed of conspiracy podcast episodes talking about various topics.
      Avoid mentioning me in the response. For example avoid something like : "you provided some episodes..."
      Your response MUST inlude a title and a summary. The summary is just a shortened version (MUST not EXCEED 200 words)
      of the context I pass to you. The title (MUST be one statement) should clearly explain what the response is about.
      Your response MUST be in the following format with the title coming first with its value
      then the summary coming second with its corresponding value. Here are some examples:

      Example 1 : "{\"title\":\"Global Controls\",\"summary\":\"The world is controlled by elite individuals\"}"
      Example 2 : "{\"title\":\"American Ponzi schemes\",\"summary\":\"Wake up now before it is too late\"}"
      """

    [
      Message.new_system!(system_message)
    ] ++
      [
        Message.new_user!(~s"""
        Context:
        --------------------------------------
        #{format_context(context)}
        --------------------------------------
        Query: #{query}
        """)
      ]
  end

  defp format_context(context) do
    context
    |> Enum.take(3)
    |> Enum.map_join("\n--------------------------------------\n", &format_episode/1)
  end

  defp format_episode(%Podcasts.Episode{} = episode) do
    ~s"""
    Episode ID: #{episode.id}
    Title: #{episode.title}
    Transcription: #{episode.transcription}
    """
  end
end
