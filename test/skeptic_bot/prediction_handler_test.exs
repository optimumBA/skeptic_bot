defmodule SkepticBot.PredictionHandlerTest do
  use SkepticBot.DataCase, async: true

  import Mox
  import SkepticBot.PromptsFixtures

  alias Ecto.Adapters.SQL.Sandbox
  alias SkepticBot.PredictionHandler
  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.QuestionsBroadcast
  alias SkepticBot.Rag.MockGenerator
  alias SkepticBot.Repo
  alias SkepticBot.Workers.SitemapGeneratorWorker

  setup :verify_on_exit!

  defp create_question(_attrs) do
    output = ["The", " tit", "le", "$", "&$", "The", " des", "crip", "tion"]
    prediction_id = "zdfjhri745"
    question = question_fixture()
    handler = start_supervised!({PredictionHandler, name: nil})
    Sandbox.allow(Repo, self(), handler)

    QuestionsBroadcast.subscribe(question.id)

    %{
      handler: handler,
      output: output,
      prediction_id: prediction_id,
      question: question
    }
  end

  describe "PredictionHandler" do
    setup [:create_question]

    test "registers a generated prediction on its own instance", %{
      handler: handler,
      prediction_id: prediction_id,
      question: question
    } do
      allow(MockGenerator, self(), handler)

      expect(MockGenerator, :predict, fn _messages, :processing_and_completed ->
        {:ok, prediction_id}
      end)

      assert :ok = GenServer.call(handler, {:params, [], question})
      assert %{^prediction_id => ^question} = :sys.get_state(handler)
    end

    test "processes messages from Replicate and sends them to the LiveView if valid",
         %{
           handler: handler,
           output: output,
           prediction_id: prediction_id,
           question: question
         } do
      send(handler, {:register_prediction, prediction_id, question})
      send(handler, {:prediction_underway, prediction_id, output})

      assert_receive {:prediction_result, {"The title", "The description"}}
    end

    test "processes messages from Replicate but does not send them if the pid was unregistered",
         %{
           handler: handler,
           output: output,
           prediction_id: prediction_id,
           question: question
         } do
      send(handler, {:register_prediction, prediction_id, question})
      send(handler, {:unregister_prediction, prediction_id})
      send(handler, {:prediction_underway, prediction_id, output})

      refute_receive {:prediction_result, {"The title", "The description"}}
    end

    test "processes messages from Replicate but does not send them if invalid",
         %{
           handler: handler,
           prediction_id: prediction_id,
           question: question
         } do
      # This is invalid because we can't decode it into a title and a description
      invalid_output = ["The", " tit", "le"]

      send(handler, {:register_prediction, prediction_id, question})
      send(handler, {:prediction_underway, prediction_id, invalid_output})

      refute_receive {:prediction_result, {_title, _description}}
    end

    test "uses the last message from Replicate to update the question",
         %{
           handler: handler,
           output: output,
           prediction_id: prediction_id,
           question: question
         } do
      send(handler, {:register_prediction, prediction_id, question})
      send(handler, {:prediction_completed, prediction_id, output})

      assert_receive {:prediction_complete, {"The title", "The description"}}
      assert map_size(:sys.get_state(handler)) == 0

      question = Prompts.get_question(question.id)
      assert question.title == "The title"
    end

    test "enqueues a sitemap job after updating the question",
         %{
           handler: handler,
           output: output,
           prediction_id: prediction_id,
           question: question
         } do
      send(handler, {:register_prediction, prediction_id, question})
      send(handler, {:prediction_completed, prediction_id, output})

      assert_receive {:prediction_complete, {"The title", "The description"}}
      assert map_size(:sys.get_state(handler)) == 0

      assert_enqueued(
        worker: SitemapGeneratorWorker,
        args: %{"question_id" => question.id},
        queue: "seo_sitemap"
      )
    end
  end
end
