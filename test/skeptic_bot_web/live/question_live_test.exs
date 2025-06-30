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

    test "displays the question query and related episodes", %{
      conn: conn,
      question: question
    } do
      related_episodes = Prompts.get_related_episodes(question.episodes)

      {:ok, _view, html} = live(conn, "/questions/#{question.id}")

      assert html =~ question.query
      assert html =~ "Related Podcasts"

      Enum.each(related_episodes, fn episode ->
        assert html =~ PodcastComponents.first_n_words(episode.title, 2)
        assert html =~ PodcastComponents.get_time_from_seconds(episode.episode_length)
      end)
    end
  end
end
