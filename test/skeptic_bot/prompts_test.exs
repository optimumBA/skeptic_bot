defmodule SkepticBot.PromptsTest do
  use SkepticBot.DataCase, async: true

  import SkepticBot.PromptsFixtures

  alias SkepticBot.Prompts

  @valid_question_attrs %{
    description: "A question description",
    embedding: Enum.map(1..1024, fn _some_random_float -> :rand.uniform() end),
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
    episodes = create_multiple_episodes(2)
    %{question: question, episodes: episodes}
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
    setup [:create_question]

    test "returns a list of podcast episodes", %{question: question} do
      episodes = Prompts.get_related_episodes(question.episodes, question.embedding, 3)
      assert Enum.all?(episodes, &is_struct(&1, SkepticBot.Podcasts.Episode))
    end
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

  describe "get_episode_details/1" do
    setup [:create_question]

    test "returns a list of episode timestamps and ids", %{episodes: episodes} do
      episode_details = Prompts.get_episode_details(episodes)

      Enum.all?(episode_details, fn detail ->
        assert detail.episode_id
        assert detail.timestamp
      end)
    end
  end
end
