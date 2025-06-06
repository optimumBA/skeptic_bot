defmodule SkepticBotWeb.QuestionLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Mox
  import Phoenix.LiveViewTest
  import SkepticBot.PromptFixtures

  alias SkepticBot.PromptsMock
  alias SkepticBotWeb.PodcastComponents

  setup :verify_on_exit!

  defp create_questions_setup(%{conn: conn}) do
    question = question_fixture(%{query: "American Ponzi with Lee Camp"})

    %{conn: conn, question: question}
  end

  describe "/questions/:id/" do
    setup [:create_questions_setup]

    test "displays the question_query, related_podcasts, other_podcasts, related_questions and the various headings",
         %{
           conn: conn,
           question: question
         } do
      related_episodes = create_multiple_episodes(4)
      other_episodes = create_multiple_episodes(3)
      related_questions = create_multiple_questions(6)

      expect(PromptsMock, :get_question_episodes, 2, fn _question_episodes ->
        related_episodes
      end)

      expect(PromptsMock, :get_other_podcast_episodes, 2, fn _most_related_episode_embedding ->
        other_episodes
      end)

      expect(PromptsMock, :get_related_questions, 2, fn _question_embedding, _question_id ->
        related_questions
      end)

      {:ok, _view, html} = live(conn, "/questions/#{question.id}")

      assert html =~ question.query
      assert html =~ "Related Podcasts"
      assert html =~ "Other Podcasts"
      assert html =~ "Related Questions"

      Enum.each(related_episodes, fn related_episode ->
        assert html =~ PodcastComponents.first_n_words(related_episode.title, 2)
        assert html =~ PodcastComponents.get_time_from_seconds(related_episode.episode_length)
      end)

      Enum.each(other_episodes, fn other_episode ->
        assert html =~ PodcastComponents.first_n_words(other_episode.title, 2)
        assert html =~ PodcastComponents.get_time_from_seconds(other_episode.episode_length)
      end)

      Enum.each(related_questions, fn related_question ->
        assert html =~ related_question.query
        assert html =~ PodcastComponents.first_n_words(related_question.description, 40)
      end)
    end
  end
end
