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
          embedding: embedding,
          episodes: [],
          title: "American Ponzi with Lee Camp and Sam Tripoli"
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

      assert html =~ ~r|<title>\s+American Ponzi with Lee Camp and Sam Tripoli\s+</title>|
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
      embedding = Pgvector.to_list(question.embedding)

      question_fixture(
        description:
          "Tupac Shakur was killed in a drive-by shooting in Las Vegas on September 7, 1996, and died six days later. For decades, the case remained officially unsolved, but in 2023, Duane “Keffe D” Davis — a former gang member — was arrested and charged with murder. According to investigators and Davis's own admissions in interviews and a memoir, he was in the car from which the fatal shots were fired and allegedly handed the gun to the shooter. While the exact individual who pulled the trigger has not been definitively confirmed in court, Davis’s arrest has provided the strongest legal and investigative breakthrough in the case to date.",
        embedding: offset_embedding_fixture(embedding),
        episodes: [],
        title: "Who killed Two Pac Shakur?"
      )

      {:ok, _view, html} = live(conn, "/questions/#{question.id}")

      assert html =~ "Related Questions"
      assert html =~ "Who killed Two Pac Shakur?"

      assert html =~
               ~r|Tupac Shakur was killed in a drive-by shooting in Las Vegas on September 7, 1996, and died six days later. For decades, the case remained officially unsolved, but in 2023, Duane “Keffe D” Davis — a former gang member — was arrested and charged with murder. According to investigators and Davi...\s+</div>|
    end

    test "disabling of the forward buttons depends on the browser width", %{
      conn: conn,
      question: question
    } do
      {:ok, view, _html} = live(conn, "/questions/#{question.id}")

      render_hook(view, "assign-batch-size", %{page_width: 1100})

      refute has_element?(view, ~s{button#next-related-btn[disabled]})
      render_click(view, :next_related_episodes)
      assert has_element?(view, ~s{button#next-related-btn[disabled]})

      {:ok, view_2, _html} = live(conn, "/questions/#{question.id}")

      render_hook(view_2, "assign-batch-size", %{page_width: 800})

      refute has_element?(view_2, ~s{button#next-related-btn[disabled]})
      render_click(view_2, :next_related_episodes)
      refute has_element?(view_2, ~s{button#next-related-btn[disabled]})
      render_click(view_2, :next_related_episodes)
      assert has_element?(view_2, ~s{button#next-related-btn[disabled]})
    end
  end
end
