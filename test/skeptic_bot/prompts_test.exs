defmodule SkepticBot.PromptsTest do
  use SkepticBot.DataCase, async: true

  import SkepticBot.PodcastsFixtures
  import SkepticBot.PromptsFixtures

  alias SkepticBot.Prompts

  @valid_question_attrs %{
    description: "A question description",
    embedding: embedding_fixture(),
    episodes: [
      %{
        episode_id: "dc6d45bc-b3ab-43ba-b106-0969e8a51c4b",
        timestamp: %{secs: 300, months: 0, days: 0}
      }
    ],
    query: "American Ponzi with Lee Camp"
  }
  @invalid_question_attrs %{
    description: "A question description",
    embedding: nil,
    episodes: nil,
    query: nil
  }

  defp create_question(_attrs) do
    question = question_fixture()

    %{question: question}
  end

  describe "create_question/1" do
    test "with valid data creates a question" do
      assert {:ok, question} = Prompts.create_question(@valid_question_attrs)
      assert question.description == "A question description"
      assert question.query == "American Ponzi with Lee Camp"
    end

    test "with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Prompts.create_question(@invalid_question_attrs)
    end
  end

  describe "get_question/1" do
    setup [:create_question]

    test "returns the question with the given id", %{question: question} do
      assert Prompts.get_question(question.id) == question
    end

    test "returns nil for non-existent question_id" do
      refute Prompts.get_question("14444444-edaa-444a-a333-7a77758ad305")
    end
  end

  describe "get_related_episodes/3" do
    test "returns a list of podcast episodes" do
      embedding = embedding_fixture()

      episode_details =
        2
        |> create_multiple_episodes(embedding)
        |> Prompts.get_episode_details()

      question = question_fixture(embedding: embedding, episodes: episode_details)
      _irrelevant_episodes = create_multiple_episodes(2)

      initial_episodes = Prompts.get_related_episodes(question.episodes, question.embedding, 6)

      assert length(initial_episodes) == 2
      assert Enum.all?(initial_episodes, &is_struct(&1, SkepticBot.Podcasts.Episode))

      _additional_relevant_episodes = create_multiple_episodes(2, embedding)

      final_episodes = Prompts.get_related_episodes(question.episodes, question.embedding, 6)

      assert length(final_episodes) == 4
    end
  end

  describe "get_other_episodes/2" do
    test "returns a list of podcast episodes" do
      create_multiple_episodes(4)
      embedding = embedding_fixture()
      episodes = Prompts.get_other_episodes(embedding, 3)

      assert length(episodes) == 3
      assert Enum.all?(episodes, &is_struct(&1, SkepticBot.Podcasts.Episode))
    end
  end

  describe "get_related_questions/2" do
    test "returns a list of questions" do
      embedding = embedding_fixture()

      _questions =
        for question <- 1..2 do
          question_fixture(%{
            description: "Number #{question} description",
            query: "Number #{question} query",
            embedding: Prompts.return_similar_embedding(embedding)
          })
        end

      question = question_fixture(embedding: embedding)

      related_questions = Prompts.get_related_questions(question.embedding, question.id)

      assert length(related_questions) == 2
      assert Enum.all?(related_questions, &is_struct(&1, SkepticBot.Prompts.UserQuestion))
    end
  end

  describe "get_episode_details/1" do
    test "returns a list of episode timestamps and ids" do
      episodes = create_multiple_episodes(1)

      episode_details = Prompts.get_episode_details(episodes)

      Enum.all?(episode_details, fn detail ->
        assert detail.episode_id
        assert detail.timestamp
      end)
    end
  end
end
