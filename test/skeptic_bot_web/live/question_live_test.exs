defmodule SkepticBotWeb.QuestionLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import SkepticBot.PodcastsFixtures
  import SkepticBot.PromptsFixtures

  defp create_question(%{conn: conn}) do
    embedding = embedding_fixture()

    create_multiple_episodes(2, embedding)

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

      {:ok, _view, html} = live(conn, ~p"/questions/#{question.id}")

      assert html =~ ~r|<title>\s+American Ponzi with Lee Camp and Sam Tripoli\s+</title>|
      assert html =~ ~r|American Ponzi with Lee Camp and Sam Tripoli\s+</p>|
      assert html =~ "Related Podcasts"
      assert html =~ "Other Podcasts"
      assert html =~ ~r|Consistency truly is key to mastering any skill over time an...\s+</div>|
      assert html =~ "00:50:00"
      assert html =~ ~r|For binaries, the default is the size of the binary. Only th...\s+</div>|
      assert html =~ "00:20:00"
    end

    test "uses different webpage_urls based on the podcast", %{
      conn: conn,
      embedding: embedding
    } do
      question =
        question_fixture(
          embedding: embedding,
          episodes: [],
          title: "American Ponzi with Lee Camp and Sam Tripoli"
        )

      episode =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding
          },
          "Tin Foil Hat"
        )

      episode_2 =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding
          },
          "Look Into It"
        )

      episode_3 =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding,
            external_id: "145321"
          },
          "Look Into It"
        )

      {:ok, _view, html} = live(conn, ~p"/questions/#{question.id}")

      webpage_url = "https://vid.samtripoli.com/w/" <> episode.external_id <> "?start=0"
      webpage_url_2 = "https://rumble.com/" <> episode_2.external_id <> "?start=0"
      webpage_url_3 = "https://rokfin.com/post/" <> episode_3.external_id <> "?start=0"

      assert html =~ webpage_url
      assert html =~ webpage_url_2
      assert html =~ webpage_url_3
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

      {:ok, _view, html} = live(conn, ~p"/questions/#{question.id}")

      assert html =~ "Related Questions"
      assert html =~ "Who killed Two Pac Shakur?"

      assert html =~
               ~r|Tupac Shakur was killed in a drive-by shooting in Las Vegas on September 7, 1996, and died six days later. For decades, the case remained officially unsolved, but in 2023, Duane “Keffe D” Davis — a former gang member — was arrested and charged with murder. According to investigators and Davi...\s+</div>|
    end

    test "updates after completing response", %{
      conn: conn,
      question: question
    } do
      {:ok, view, _html} = live(conn, ~p"/questions/#{question.id}")

      send(view.pid, {:prediction_result, {"New Title", "New Description"}})

      html = render(view)
      assert html =~ "New Title"
      assert html =~ "New Description"
    end

    test "removes the loader after completing response",
         %{
           conn: conn,
           question: question
         } do
      {:ok, view, _html} = live(conn, ~p"/questions/#{question.id}")

      send(view.pid, {:prediction_complete, {"New Title", "New Description"}})

      assert has_element?(view, ~s{div#loading-elements.hidden})
    end

    test "handles questions with episodes but no transcription embeddings", %{
      conn: conn,
      embedding: embedding
    } do
      # Create episodes with embeddings
      _episode1 =
        episode_fixture(%{
          title: "Episode with no transcriptions",
          embedding: embedding
        })

      episode2 =
        episode_fixture(%{
          title: "Episode with non-embedded transcriptions",
          embedding: offset_embedding_fixture(embedding, 0.01)
        })

      # Add transcription without embedding to episode2
      transcription_fixture(%{
        podcast_episode_id: episode2.id,
        embedding: nil,
        transcription: "This transcription has no embedding"
      })

      question =
        question_fixture(
          embedding: embedding,
          episodes: [],
          title: "Question with problematic episodes"
        )

      {:ok, _view, html} = live(conn, ~p"/questions/#{question.id}")

      # Should still render without errors
      assert html =~ "Question with problematic episodes"
      # Episodes should still show up
      assert html =~ "Episode with no transcriptions"
      assert html =~ "Episode with non-embedded transcriptions"
    end
  end
end
