defmodule SkepticBotWeb.QuestionLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import SkepticBot.PodcastsFixtures
  import SkepticBot.PromptsFixtures

  alias SkepticBot.Prompts

  defp create_question(%{conn: conn}) do
    embedding = embedding_fixture()

    episode_details =
      5
      |> create_multiple_episodes(embedding)
      |> Prompts.get_episode_details()

    question = question_fixture(embedding: embedding, episodes: episode_details)
    %{conn: conn, question: question}
  end

  describe "/questions/:id/" do
    setup [:create_question]

    test "displays the question query, related episodes and other episodes", %{
      conn: conn,
      question: question
    } do
      {:ok, _view, html} = live(conn, "/questions/#{question.id}")

      assert html =~ "American Ponzi with Lee Camp and"
      assert html =~ "Related Podcasts"
      assert html =~ "Other Podcasts"
      assert html =~ "Consistency truly is key to mastering any skill over time and"
      assert html =~ "00:50:00"
    end

    test "renders carousel with related episodes and translates appropriately with click events",
         %{
           conn: conn,
           question: question
         } do
      {:ok, view, html} = live(conn, "/questions/#{question.id}")

      assert html =~ ~s'id="related-episodes-carousel" style="transform: translateX(-0.0rem);"'

      assert render_click(view, :next_related_episodes) =~
               ~s'id="related-episodes-carousel" style="transform: translateX(-20.6875rem);"'

      assert render_click(view, :prev_related_episodes) =~
               ~s'id="related-episodes-carousel" style="transform: translateX(-0.0rem);"'
    end

    test "renders carousel with other episodes and translates appropriately with click events",
         %{
           conn: conn,
           question: question
         } do
      {:ok, view, html} = live(conn, "/questions/#{question.id}")

      assert html =~ ~s'id="other-episodes-carousel" style="transform: translateX(-0.0rem);"'

      assert render_click(view, :next_other_episodes) =~
               ~s'id="other-episodes-carousel" style="transform: translateX(-20.6875rem);"'

      assert render_click(view, :prev_other_episodes) =~
               ~s'id="other-episodes-carousel" style="transform: translateX(-0.0rem);"'
    end
  end
end
