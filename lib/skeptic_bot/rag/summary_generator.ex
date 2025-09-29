defmodule SkepticBot.Rag.SummaryGenerator do
  @moduledoc """
  Generates teasers and summaries for podcast episodes
  """

  alias LangChain.Message
  alias SkepticBot.Podcasts
  alias SkepticBot.Rag

  @type episode :: Podcasts.Episode.t()
  @type summary :: String.t()
  @type teaser :: String.t()

  @spec generate_teaser_and_summary(episode()) ::
          {:ok, {teaser(), summary()}}
          | {:error, String.t()}
  def generate_teaser_and_summary(episode) do
    with {:ok, transcription} <- Podcasts.get_episode_transcriptions(episode.id),
         episode <- Map.put(episode, :trancription, transcription),
         prompt <- format_prompt(episode),
         {:ok, response} <- Rag.Generator.predict(prompt, :completed) do
      {teaser, summary} = process_response(response)
      {:ok, {teaser, summary}}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp format_prompt(episode) do
    system_message =
      ~s"""
      You are a skeptic.
      You don't believe official naratives and are open to all opinions.
      Read the content that I will give you and provide a teaser of it in 300 words or less.
      Also provide a summary of the content in 600 words or less.
      The teaser should not reveal a lot of details and should strive to arouse CURIOSITY from the reader.
      The teaser should be very engaging and unique enough that it will immediately entice the reader to listen to the podcast episode.
      On the other hand, the summary should be VERY DETAILED and MENTION the names of the speakers if possible.
      The reader of the summary should be THOROUGHLY INFORMED and not have to seek FURTHER INFORMATION.
      Please return your response in the following format with the TEASER coming first
      then the SUMMARY coming second separated by $&$ signs.

      FOLLOW this format to THE LETTER:

      Format: "Teaser: Two Pac shakur was murdered in cold blood on the eve of 12th January ... He was killed by Gang Member Dennis O'brien$&$Summary: It is not clear how Two Pac shakur met his untimely demise but word says it was due to a bullet wound ... Further investigations suggest otherwise"

      You MUST not reveal your identity in the response.
      """

    [
      Message.new_system!(system_message)
    ] ++
      [
        Message.new_user!(~s"""
        Content:
        --------------------------------------
        #{format_episode(episode)}
        """)
      ]
  end

  defp format_episode(%Podcasts.Episode{} = episode) do
    ~s"""
    Title: #{episode.title}
    Transcription: #{episode.transcription}
    """
  end

  defp process_response(response) do
    [teaser, summary] =
      response
      |> String.split("$&$", parts: 2)
      |> Enum.map(fn text -> String.trim(text) end)

    <<"Teaser:", processed_teaser::binary>> = teaser
    <<"Summary:", processed_summary::binary>> = summary

    {processed_teaser, processed_summary}
  end
end
