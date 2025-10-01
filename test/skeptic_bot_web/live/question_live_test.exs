defmodule SkepticBotWeb.QuestionLiveTest do
  use SkepticBotWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import SkepticBot.PodcastsFixtures
  import SkepticBot.PromptsFixtures

  defp create_question(%{conn: conn}) do
    embedding = embedding_fixture()

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

    test "uses Rokfin and Rumble urls for podcasts hosted on Rokfin and Rumble",
         %{
           conn: conn,
           embedding: embedding
         } do
      episode =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding,
            external_id:
              "v51g8i8-alex-jones-on-look-into-it-with-eddie-bravo-episode-101.html?e9s=src_v1_ucp_a"
          },
          "Look Into It"
        )

      episode_2 =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding,
            external_id: "145321"
          },
          "Look Into It"
        )

      question =
        question_fixture(
          embedding: embedding,
          episodes: [
            %{episode_id: episode.id, timestamp: %{secs: 30, months: 0, days: 0}},
            %{episode_id: episode_2.id, timestamp: %{secs: 20, months: 0, days: 0}}
          ],
          title: "American Ponzi with Lee Camp and Sam Tripoli"
        )

      {:ok, _view, html} = live(conn, ~p"/questions/#{question.id}")

      webpage_url =
        "https://rumble.com/v51g8i8-alex-jones-on-look-into-it-with-eddie-bravo-episode-101.html?e9s=src_v1_ucp_a&amp;start=30"

      webpage_url_2 = "https://rokfin.com/post/145321?start=20"

      assert html =~ webpage_url
      assert html =~ webpage_url_2
    end

    test "uses YouTube urls for podcasts hosted on YouTube",
         %{
           conn: conn,
           embedding: embedding
         } do
      episode =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding,
            external_id: "PrRzUqsG930"
          },
          "Broken Simulation"
        )

      episode_2 =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding,
            external_id: "PrRzUesG840"
          },
          "Candace"
        )

      episode_3 =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding,
            external_id: "ErRzUmsG800"
          },
          "Deep Waters"
        )

      episode_4 =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding,
            external_id: "DoRzUmsF800"
          },
          "Nephilim Death Squad"
        )

      question =
        question_fixture(
          embedding: embedding,
          episodes: [
            %{episode_id: episode.id, timestamp: %{secs: 45, months: 0, days: 0}},
            %{episode_id: episode_2.id, timestamp: %{secs: 30, months: 0, days: 0}},
            %{episode_id: episode_3.id, timestamp: %{secs: 20, months: 0, days: 0}},
            %{episode_id: episode_4.id, timestamp: %{secs: 76, months: 0, days: 0}}
          ],
          title: "American Ponzi with Lee Camp and Sam Tripoli"
        )

      {:ok, _view, html} = live(conn, ~p"/questions/#{question.id}")

      webpage_url = "https://www.youtube.com/watch?v=PrRzUqsG930?start=45"
      webpage_url_2 = "https://www.youtube.com/watch?v=PrRzUesG840?start=30"
      webpage_url_3 = "https://www.youtube.com/watch?v=ErRzUmsG800?start=20"
      webpage_url_4 = "https://www.youtube.com/watch?v=DoRzUmsF800?start=76"

      assert html =~ webpage_url
      assert html =~ webpage_url_2
      assert html =~ webpage_url_3
      assert html =~ webpage_url_4
    end

    test "uses Sam Tripoli urls for podcasts hosted on Sam Tripoli's website",
         %{
           conn: conn,
           embedding: embedding
         } do
      episode =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding,
            external_id: "ohLn3qfgHh49f7JomvEpoB"
          },
          "Cash Daddies"
        )

      episode_2 =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding,
            external_id: "edLn3qfgHh49f7JomvEpoI"
          },
          "Doom Scrollin"
        )

      episode_3 =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding,
            external_id: "ohUn8qfgHh49f7JomvYpoH"
          },
          "Tin Foil Hat"
        )

      episode_4 =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding,
            external_id: "rhUn9qfgHh39f7JomvYpoH"
          },
          "Union of the Unwanted"
        )

      episode_5 =
        episode_fixture(
          %{
            episode_length: 3000,
            title: "Consistency truly is key to mastering any skill over time and effort",
            embedding: embedding,
            external_id: "ioUn9qwsHh39f7KomvYpoE"
          },
          "Zero with Sam Tripoli"
        )

      question =
        question_fixture(
          embedding: embedding,
          episodes: [
            %{episode_id: episode.id, timestamp: %{secs: 45, months: 0, days: 0}},
            %{episode_id: episode_2.id, timestamp: %{secs: 30, months: 0, days: 0}},
            %{episode_id: episode_3.id, timestamp: %{secs: 20, months: 0, days: 0}},
            %{episode_id: episode_4.id, timestamp: %{secs: 46, months: 0, days: 0}},
            %{episode_id: episode_5.id, timestamp: %{secs: 76, months: 0, days: 0}}
          ],
          title: "American Ponzi with Lee Camp and Sam Tripoli"
        )

      {:ok, _view, html} = live(conn, ~p"/questions/#{question.id}")

      webpage_url = "https://vid.samtripoli.com/w/ohLn3qfgHh49f7JomvEpoB?start=45"
      webpage_url_2 = "https://vid.samtripoli.com/w/edLn3qfgHh49f7JomvEpoI?start=30"
      webpage_url_3 = "https://vid.samtripoli.com/w/ohUn8qfgHh49f7JomvYpoH?start=20"
      webpage_url_4 = "https://vid.samtripoli.com/w/rhUn9qfgHh39f7JomvYpoH?start=46"
      webpage_url_5 = "https://vid.samtripoli.com/w/ioUn9qwsHh39f7KomvYpoE?start=76"

      assert html =~ webpage_url
      assert html =~ webpage_url_2
      assert html =~ webpage_url_3
      assert html =~ webpage_url_4
      assert html =~ webpage_url_5
    end

    test "displays the related questions", %{
      conn: conn,
      embedding: embedding,
      question: question
    } do
      create_multiple_episodes(2, embedding)

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

    test "does not display the related questions that don't have a title", %{
      conn: conn,
      embedding: embedding,
      question: question
    } do
      create_multiple_episodes(2, embedding)

      embedding = Pgvector.to_list(question.embedding)

      question_fixture(
        description:
          "Tupac Shakur was killed in a drive-by shooting in Las Vegas on September 7, 1996, and died six days later. For decades, the case remained officially unsolved, but in 2023, Duane “Keffe D” Davis — a former gang member — was arrested and charged with murder. According to investigators and Davis's own admissions in interviews and a memoir, he was in the car from which the fatal shots were fired and allegedly handed the gun to the shooter. While the exact individual who pulled the trigger has not been definitively confirmed in court, Davis’s arrest has provided the strongest legal and investigative breakthrough in the case to date.",
        embedding: offset_embedding_fixture(embedding),
        episodes: [],
        title: nil
      )

      {:ok, _view, html} = live(conn, ~p"/questions/#{question.id}")

      assert html =~ "Related Questions"

      refute html =~
               ~r|Tupac Shakur was killed in a drive-by shooting in Las Vegas on September 7, 1996, and died six days later. For decades, the case remained officially unsolved, but in 2023, Duane “Keffe D” Davis — a former gang member — was arrested and charged with murder. According to investigators and Davi...\s+</div>|
    end

    test "updates after completing response", %{
      conn: conn,
      embedding: embedding,
      question: question
    } do
      create_multiple_episodes(2, embedding)
      {:ok, view, _html} = live(conn, ~p"/questions/#{question.id}")

      send(view.pid, {:prediction_result, {"New Title", "New Description"}})

      html = render(view)
      assert html =~ "New Title"
      assert html =~ "New Description"
    end

    test "removes the loader after completing response",
         %{
           conn: conn,
           embedding: embedding,
           question: question
         } do
      create_multiple_episodes(2, embedding)
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
