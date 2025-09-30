defmodule SkepticBot.Podcasts.SummaryGeneratingWorkerTest do
  use SkepticBot.DataCase, async: true

  import ExUnit.CaptureLog
  import Mox
  import SkepticBot.PodcastsFixtures

  alias SkepticBot.Podcasts
  alias SkepticBot.Podcasts.SummaryGeneratingWorker
  alias SkepticBot.Rag.EmbeddingsGeneratingWorker
  alias SkepticBot.Rag.MockGenerator

  @id "a909da70-13b7-4717-b1c0-c2d001521dc3"

  setup :verify_on_exit!

  defp create_episode(_attrs) do
    response =
      "Teaser:A Sam Tripoli episode teaser $&$ Summary:A Sam Tripoli episode summary"

    episode = episode_fixture()
    %{episode: episode, response: response}
  end

  describe "perform/1" do
    setup [:create_episode]

    test "generates a teaser and a summary and enqueues an embedding_worker job for episodes",
         %{
           response: response,
           episode: episode
         } do
      expect(MockGenerator, :predict, fn _messages, _output_mode ->
        {:ok, response}
      end)

      assert :ok =
               perform_job(SummaryGeneratingWorker, %{
                 "id" => episode.id,
                 "episode_status" => "existing"
               })

      updated_episode = Podcasts.get_episode(episode.id)
      assert updated_episode.teaser == "A Sam Tripoli episode teaser"
      assert updated_episode.summary == "A Sam Tripoli episode summary"

      assert_enqueued(
        worker: EmbeddingsGeneratingWorker,
        args: %{
          "id" => episode.id
        }
      )
    end

    test "logs an error when teaser generation fails" do
      log =
        capture_log(fn ->
          perform_job(SummaryGeneratingWorker, %{
            "id" => @id,
            "episode_status" => "new"
          })
        end)

      assert log =~ "Failed to process episode:"
    end

    @tag :capture_log
    test "returns an error when it fails to generate the teaser and summary",
         %{
           episode: episode
         } do
      expect(MockGenerator, :predict, fn _text, _output_mode ->
        {:error, "failed to generate a teaser and summary"}
      end)

      assert {:error, "failed to generate a teaser and summary"} =
               perform_job(SummaryGeneratingWorker, %{
                 "id" => episode.id,
                 "episode_status" => "existing"
               })
    end
  end
end
