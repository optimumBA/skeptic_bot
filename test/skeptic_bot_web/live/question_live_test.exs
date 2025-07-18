defmodule SkepticBotWeb.QuestionLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import SkepticBot.PodcastsFixtures
  import SkepticBot.PromptsFixtures

  defp create_question(%{conn: conn}) do
    embedding = embedding_fixture()

    create_multiple_episodes(4, embedding)

    question = question_fixture(embedding: embedding)

    %{conn: conn, embedding: embedding, question: question}
  end

  describe "/questions/:id/" do
    setup [:create_question]

    test "displays the question query, related episodes and other episodes", %{
      conn: conn,
      embedding: embedding
    } do
      question =
        question_fixture(
          query: "American Ponzi with Lee Camp and Sam Tripoli",
          embedding: embedding,
          episodes: []
        )

      episode_fixture(%{
        episode_length: 3000,
        title: "Consistency truly is key to mastering any skill over time and effort",
        embedding: embedding
      })

      episode_fixture(%{
        episode_length: 1200,
        title:
          "For binaries, the default is the size of the binary. Only the last binary in a match can use the default size.",
        embedding: nil
      })

      {:ok, _view, html} = live(conn, "/questions/#{question.id}")

      assert html =~ ~r|American Ponzi with Lee Camp and Sam Tripoli\s+</p>|
      assert html =~ "Related Podcasts"
      assert html =~ "Other Podcasts"
      assert html =~ ~r|Consistency truly is key to mastering any skill over time an...\s+</div>|
      assert html =~ "00:50:00"
      assert html =~ ~r|For binaries, the default is the size of the binary. Only th...\s+</div>|
      assert html =~ "00:20:00"
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

    test "displays the related questions", %{
      conn: conn,
      question: question
    } do
      question_fixture(
        description: "He was allegedly killed by some gang members",
        embedding: embedding_fixture(),
        episodes: [],
        query: "Who killed Two Pac Shakur?"
      )

      {:ok, _view, html} = live(conn, "/questions/#{question.id}")

      assert html =~ "Related Questions"
      assert html =~ "Who killed Two Pac Shakur?"
      assert html =~ "He was allegedly killed by some gang members"
    end
  end
end
