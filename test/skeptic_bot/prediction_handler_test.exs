defmodule SkepticBot.PredictionHandlerTest do
  use SkepticBot.DataCase, async: true

  import SkepticBot.PromptsFixtures

  alias Ecto.Adapters.SQL.Sandbox
  alias SkepticBot.PredictionHandler
  alias SkepticBot.Prompts
  alias SkepticBot.Repo

  defp create_question(_attrs) do
    question = question_fixture()
    prediction_id = "zdfjhri745"
    output = ["The", " tit", "le", "$", "&$", "The", " des", "crip", "tion"]

    %{
      prediction_id: prediction_id,
      question: question,
      output: output
    }
  end

  describe "/" do
    setup [:create_question]

    test "prediction handler processes messages from Replicate and sends them if valid", %{
      prediction_id: prediction_id,
      question: question,
      output: output
    } do
      send(PredictionHandler, {:register_prediction, prediction_id, {self(), question}})

      gen_server_state = :sys.get_state(PredictionHandler)
      assert gen_server_state[prediction_id]

      send(PredictionHandler, {:prediction_underway, prediction_id, output})
      assert_receive {:prediction_result, {"The title", "The description"}}
    end

    test "prediction handler processes messages from Replicate and but does not send them if pid was unregistered",
         %{
           prediction_id: prediction_id,
           question: question,
           output: output
         } do
      send(PredictionHandler, {:register_prediction, prediction_id, {self(), question}})
      send(PredictionHandler, {:unregister_prediction, prediction_id})
      send(PredictionHandler, {:prediction_underway, prediction_id, output})

      gen_server_state = :sys.get_state(PredictionHandler)
      refute gen_server_state[prediction_id]

      refute_receive {:prediction_result, {"The title", "The description"}}
    end

    test "prediction handler processes messages from Replicate and but does not send them if invalid",
         %{
           prediction_id: prediction_id,
           question: question
         } do
      output = ["The", " tit", "le"]

      send(PredictionHandler, {:register_prediction, prediction_id, {self(), question}})
      send(PredictionHandler, {:prediction_underway, prediction_id, output})

      refute_receive {:prediction_result, {_title, _description}}
    end

    test "prediction handler uses the last message from Replicate to update the question",
         %{
           prediction_id: prediction_id,
           question: question,
           output: output
         } do
      allow = Process.whereis(PredictionHandler)
      Sandbox.allow(Repo, self(), allow)

      send(PredictionHandler, {:register_prediction, prediction_id, {self(), question}})
      send(PredictionHandler, {:prediction_completed, prediction_id, output})

      Process.sleep(1000)
      question = Prompts.get_question(question.id)
      assert question.title == "The title"
      assert question.description == "The description"

      assert_receive {:prediction_result, {"The title", "The description"}}
    end
  end
end
