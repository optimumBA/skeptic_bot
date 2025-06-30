defmodule SkepticBotWeb.QuestionLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import SkepticBot.PromptsFixtures

  alias SkepticBot.Prompts
  alias SkepticBotWeb.PodcastComponents

  defp create_question(%{conn: conn}) do
    question = question_fixture()
    %{conn: conn, question: question}
  end

  describe "/questions/:id/" do
    setup [:create_question]

    test "displays the question query, related episodes and other episodes", %{
      conn: conn,
      question: question
    } do
      {:ok, _view, html} = live(conn, "/questions/#{question.id}")

      assert html =~ question.query
      assert html =~ "Related Podcasts"
      assert html =~ "Other Podcasts"

      related_episodes = Prompts.get_related_episodes(question.episodes)
      [most_related_episode | _other_related_episodes] = related_episodes
      other_episodes = Prompts.get_other_episodes(most_related_episode.embedding)

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
