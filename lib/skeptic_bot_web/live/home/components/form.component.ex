defmodule SkepticBotWeb.HomeLive.FormComponent do
  @moduledoc """
  Our form component.

  Forwads the user Prompt to the LLM.
  """

  use SkepticBotWeb, :live_component

  alias SkepticBot.{Prompt}

  alias SkepticBot.Prompt.Question

  @impl Phoenix.LiveComponent
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
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
     |> assign(:question, %Question{})
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
      |> Prompt.change_prompt_question(prompt_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset, as: "prompt"))}
  end

  def handle_event(
        "save",
        %{"prompt" => %{"query" => query} = prompt_params},
        %{assigns: %{question: question}} = socket
      ) do
    changeset =
      question
      |> Prompt.change_prompt_question(prompt_params)

    maybe_generate_prompt_results(changeset.valid?, query, question)

    {:noreply, socket}
  end

  defp maybe_generate_prompt_results(false, _query, _question) do
    :ok
  end

  defp maybe_generate_prompt_results(true, query, question) do
    caller = self()
    send(caller, {:loading, true})

    Task.start(fn ->
      result = SkepticBot.Rag.generate(query)
      send(caller, {:generation_done, result, {query, question}})
    end)
  end

  def assign_form(%{assigns: %{question: question}} = socket) do
    socket
    |> assign(:form, to_form(Prompt.change_prompt_question(question), as: "prompt"))
  end
end
