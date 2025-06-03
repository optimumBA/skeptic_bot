defmodule SkepticBotWeb.HomeLive.QuestionFormComponent do
  @moduledoc """
  Our form component.
  Forwads the user Prompt to the LLM.
  """

  use SkepticBotWeb, :live_component

  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.UserQuestion

  @type socket :: Phoenix.LiveView.Socket.t()
  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.form
        for={@form}
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        id="prompt-input-form"
      >
        <div class="flex justify-between mt-8 items-center rounded-xl hover:cursor-pointer custom-shadow border bg-[#FFFFFF] py-2">
          <div class="w-2/3 grow pl-4">
            <.input
              placeholder="Ask anything"
              field={@form[:query]}
              autocomplete="off"
              phx-debounce="1000"
            />
          </div>

          <.button
            type="submit"
            class="hover:cursor-pointer text-[#FFFFFF] bg-[#CD4631] transition ease-in-out duration-300 my-3 mr-4"
          >
            <div class="flex flex-row gap-2 items-center">
              <div class="pl-2">
                <img src={~p"/images/home/search_icon.svg"} alt="Search Icon" />
              </div>

              <section class="montserrat-alternates-medium">Search...</section>
            </div>
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl Phoenix.LiveComponent
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:question, %UserQuestion{})
     |> assign_form()}
  end

  @impl Phoenix.LiveComponent
  def handle_event(
        "validate",
        %{"prompt" => prompt_params},
        %{assigns: %{question: question}} = socket
      ) do
    changeset =
      question
      |> Prompts.change_prompt_question(prompt_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset, as: "prompt"))}
  end

  def handle_event(
        "save",
        %{"prompt" => %{"query" => query} = prompt_params},
        %{assigns: %{question: question}} = socket
      ) do
    changeset =
      Prompts.change_prompt_question(question, prompt_params)

    maybe_generate_prompt_results(changeset.valid?, query)

    {:noreply, socket}
  end

  defp maybe_generate_prompt_results(false, _query) do
    :ok
  end

  defp maybe_generate_prompt_results(true, query) do
    caller = self()
    send(caller, {:loading_state, true})

    Task.start(fn ->
      {:ok, {description, list_of_episodes}} = get_rag_module().generate(query)

      if list_of_episodes == [] do
        send(caller, :no_episodes_found)
        send(caller, {:loading_state, false})
      else
        send(caller, {:generation_done, {description, list_of_episodes, query}})
      end
    end)
  end

  @spec assign_form(socket()) :: socket()
  def assign_form(%{assigns: %{question: question}} = socket) do
    assign(socket, :form, to_form(Prompts.change_prompt_question(question), as: "prompt"))
  end

  defp get_rag_module do
    Application.get_env(:skeptic_bot, :rag_module, SkepticBot.Rag)
  end
end
