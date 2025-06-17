defmodule SkepticBotWeb.QuestionLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Mox
  import Phoenix.LiveViewTest
  import SkepticBot.PromptFixtures

  alias SkepticBot.Prompts
  alias SkepticBotWeb.PodcastComponents

  setup :verify_on_exit!

  defp create_question_setup(%{conn: conn}) do
    question = question_fixture(%{query: "American Ponzi with Lee Camp"})
    _random_episodes = create_multiple_episodes(4)
    %{conn: conn, question: question}
  end

  describe "/questions/:id/" do
    setup [:create_question_setup]

    test "displays the question_query, related_podcasts, other_podcasts, related_questions and the various headings",
         %{
           conn: conn,
           question: question
         } do
      {:ok, _view, html} = live(conn, "/questions/#{question.id}")

      assert html =~ question.query
      assert html =~ "Related Podcasts"
      assert html =~ "Other Podcasts"

      related_episodes = Prompts.get_question_episodes(question.episodes)
      [most_related_episode | _other_related_episodes] = related_episodes
      other_episodes = Prompts.get_other_podcast_episodes(most_related_episode.embedding)

      Enum.each(related_episodes, fn related_episode ->
        assert html =~ PodcastComponents.first_n_words(related_episode.title, 2)
        assert html =~ PodcastComponents.get_time_from_seconds(related_episode.episode_length)
      end)

      Enum.each(other_episodes, fn other_episode ->
        assert html =~ PodcastComponents.first_n_words(other_episode.title, 2)
        assert html =~ PodcastComponents.get_time_from_seconds(other_episode.episode_length)
      end)
    end
  end
end
