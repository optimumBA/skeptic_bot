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
      {:ok, _view, html} = live(conn, "/questions/#{question.id}")

      assert html =~ question.query
      assert html =~ "Related Podcasts"

      related_episodes =
        Prompts.get_related_episodes(question.episodes, question.embedding, 6)

      Enum.each(related_episodes, fn episode ->
        assert html =~ PodcastComponents.first_n_words(episode.title, 2)
        assert html =~ PodcastComponents.get_time_from_seconds(episode.episode_length)
      end)
    end

    test "renders carousel with related episodes and translates appropriately with click events",
         %{
           conn: conn,
           question: question
         } do
      {:ok, view, _html} = live(conn, "/questions/#{question.id}")

      assert render(view) =~ "style=\"transform: translateX(-0.0rem);\""
      render_click(view, :next_related_episodes)
      assert render(view) =~ "style=\"transform: translateX(-20.6875rem);\""
      render_click(view, :prev_related_episodes)
      assert render(view) =~ "style=\"transform: translateX(-0.0rem);\""
    end
  end
end
