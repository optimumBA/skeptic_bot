defmodule SkepticBot.PredictionHandlerTest do
  use SkepticBot.DataCase, async: true

  import SkepticBot.PromptsFixtures

  alias Ecto.Adapters.SQL.Sandbox
  alias SkepticBot.PredictionHandler
  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.QuestionsBroadcast
  alias SkepticBot.Repo
  alias SkepticBot.Workers.SitemapGeneratorWorker

  defp create_question(_attrs) do
    output = ["The", " tit", "le", "$", "&$", "The", " des", "crip", "tion"]
    prediction_id = "zdfjhri745"
    question = question_fixture()

    QuestionsBroadcast.subscribe(question.id)

    %{
      output: output,
      prediction_id: prediction_id,
      question: question
    }
  end

  describe "PredictionHandler" do
    setup [:create_question]

    test "processes messages from Replicate and sends them to the LiveView if valid",
         %{
           output: output,
           prediction_id: prediction_id,
           question: question
         } do
      send(PredictionHandler, {:register_prediction, prediction_id, question})
      send(PredictionHandler, {:prediction_underway, prediction_id, output})

      assert_receive {:prediction_result, {"The title", "The description"}}
    end

    test "processes messages from Replicate but does not send them if the pid was unregistered",
         %{
           output: output,
           prediction_id: prediction_id,
           question: question
         } do
      send(PredictionHandler, {:register_prediction, prediction_id, question})
      send(PredictionHandler, {:unregister_prediction, prediction_id})
      send(PredictionHandler, {:prediction_underway, prediction_id, output})

      refute_receive {:prediction_result, {"The title", "The description"}}
    end

    test "processes messages from Replicate but does not send them if invalid",
         %{
           prediction_id: prediction_id,
           question: question
         } do
      # This is invalid because we can't decode it into a title and a description
      invalid_output = ["The", " tit", "le"]

      send(PredictionHandler, {:register_prediction, prediction_id, question})
      send(PredictionHandler, {:prediction_underway, prediction_id, invalid_output})

      refute_receive {:prediction_result, {_title, _description}}
    end

    test "uses the last message from Replicate to update the question",
         %{
           output: output,
           prediction_id: prediction_id,
           question: question
         } do
      gen_server_pid = Process.whereis(PredictionHandler)
      Sandbox.allow(Repo, self(), gen_server_pid)

      send(PredictionHandler, {:register_prediction, prediction_id, question})
      send(PredictionHandler, {:prediction_completed, prediction_id, output})

      assert_receive {:prediction_complete, {"The title", "The description"}}

      question = Prompts.get_question(question.id)
      assert question.title == "The title"
    end

    test "enqueues a sitemap job after updating the question",
         %{
           output: output,
           prediction_id: prediction_id,
           question: question
         } do
      gen_server_pid = Process.whereis(PredictionHandler)
      Sandbox.allow(Repo, self(), gen_server_pid)

      send(PredictionHandler, {:register_prediction, prediction_id, question})
      send(PredictionHandler, {:prediction_completed, prediction_id, output})

      Process.sleep(200)

      assert_enqueued(
        worker: SitemapGeneratorWorker,
        args: %{"question_id" => question.id},
        queue: "seo_sitemap"
      )
    end
  end
end
