defmodule SkepticBot.PredictionHandlerTest do
  use SkepticBot.DataCase, async: true

  import SkepticBot.PromptsFixtures

  alias Ecto.Adapters.SQL.Sandbox
  alias SkepticBot.PredictionHandler
  alias SkepticBot.Prompts.QuestionsBroadcast
  alias SkepticBot.Repo

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

      gen_server_state = :sys.get_state(PredictionHandler)
      assert gen_server_state[prediction_id]

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

      gen_server_state = :sys.get_state(PredictionHandler)
      refute gen_server_state[prediction_id]

      refute_receive {:prediction_result, {"The title", "The description"}}
    end

    test "processes messages from Replicate and but does not send them if invalid",
         %{
           prediction_id: prediction_id,
           question: question
         } do
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
      allow = Process.whereis(PredictionHandler)
      Sandbox.allow(Repo, self(), allow)

      send(PredictionHandler, {:register_prediction, prediction_id, question})
      send(PredictionHandler, {:prediction_completed, prediction_id, output})

      assert_receive {:prediction_complete, {"The title", "The description"}}
    end
  end
end
