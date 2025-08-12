defmodule SkepticBot.PredictionHandler do
  @moduledoc """
  concerned with predictions with status processing
  """

  use GenServer

  alias SkepticBot.Prompts
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

  @spec make_llm_request(context(), question(), pid()) :: :ok
  def make_llm_request(context, question, pid) do
    GenServer.cast(__MODULE__, {:params, context, question, pid})
  end

  @impl GenServer
  def handle_cast({:params, context, question, pid}, state) do
    {:ok, prediction_id} = Rag.predict_query(context, question.query)
    new_state = Map.put(state, prediction_id, {pid, question})
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_info({:prediction_underway, prediction_id, output}, state) do
    {pid, _question} = state[prediction_id]

    _result =
      case get_title_and_description(output) do
        [title, description] ->
          send(pid, {:prediction_result, {title, description}})

        [_title] ->
          :ok
      end

    {:noreply, state}
  end

  def handle_info({:prediction_completed, prediction_id, output}, state) do
    {pid, question} = state[prediction_id]
    [title, description] = get_title_and_description(output)

    send(pid, {:prediction_result, {title, description}})

    Prompts.update_question(question, %{description: description, title: title})

    new_state = Map.drop(state, [prediction_id])

    {:noreply, new_state}
  end

  defp get_title_and_description(output) do
    output
    |> Enum.join()
    |> String.split("$&$", parts: 2)
  end
end
