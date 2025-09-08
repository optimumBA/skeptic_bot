defmodule SkepticBot.PredictionHandler do
  @moduledoc """
  Processes predictions with status 'processing'
  and routes results to the LiveView
  """

  use GenServer

  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.QuestionsBroadcast
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBot.Rag

  @type context :: list()
  @type question :: UserQuestion.t()

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_state) do
    {:ok, %{}}
  end

  @spec make_llm_request(context(), question()) :: :ok
  def make_llm_request(context, question) do
    GenServer.call(__MODULE__, {:params, context, question})
  end

  @impl GenServer
  def handle_call({:params, context, question}, _from, state) do
    {:ok, prediction_id} = Rag.predict_query(context, question.query)

    send(__MODULE__, {:register_prediction, prediction_id, question})

    {:reply, :ok, state}
  end

  @impl GenServer
  def handle_info({:register_prediction, prediction_id, question}, state) do
    new_state = Map.put(state, prediction_id, question)
    {:noreply, new_state}
  end

  def handle_info({:unregister_prediction, prediction_id}, state) do
    new_state = Map.drop(state, [prediction_id])
    {:noreply, new_state}
  end

  def handle_info({:prediction_underway, prediction_id, output}, state) do
    _result =
      with %UserQuestion{id: question_id} <- Map.get(state, prediction_id),
           [title, description] <- get_title_and_description(output) do
        QuestionsBroadcast.broadcast_title_and_description(
          question_id,
          {:prediction_result, {title, description}}
        )
      else
        _error -> :ok
      end

    {:noreply, state}
  end

  def handle_info({:prediction_failed, _prediction_id, _output}, state) do
    {:noreply, state}
  end

  def handle_info({:prediction_completed, prediction_id, output}, state) do
    question = state[prediction_id]
    [title, description] = get_title_and_description(output)

    Prompts.update_question(question, %{description: description, title: title})

    QuestionsBroadcast.broadcast_title_and_description(
      question.id,
      {:prediction_complete, {title, description}}
    )

    send(__MODULE__, {:unregister_prediction, prediction_id})

    {:noreply, state}
  end

  defp get_title_and_description(output) do
    output
    |> Enum.join()
    |> String.split("$&$", parts: 2)
  end
end
