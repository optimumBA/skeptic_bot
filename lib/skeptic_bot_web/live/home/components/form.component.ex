defmodule SkepticBotWeb.HomeLive.FormComponent do
  @moduledoc """
  Our form component.

  Forwads the user Prompt to the LLM.
  """

  use SkepticBotWeb, :live_component

  alias SkepticBot.{Rag, Repo, Prompt}

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

  def assign_form(%{assigns: %{question: question}} = socket) do
    socket
    |> assign(:form, to_form(Prompt.change_prompt_question(question), as: "prompt"))
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

  @impl true
  def handle_event(
        "save",
        %{"prompt" => %{"query" => query} = prompt_params},
        %{assigns: %{question: question}} = socket
      ) do
    # American Ponzi With Lee Camp
    changeset =
      question
      |> Prompt.change_prompt_question(prompt_params)

    case changeset.valid? do
      true ->
        {description, list_of_episodes} = SkepticBot.Rag.generate(query)

        list_of_ids =
          Enum.reduce(list_of_episodes, [], fn episode, list ->
            [%{episode_id: episode.id} | list]
          end)

        embedding_value = query <> " " <> description

        embedding = Rag.Embedding.generate(embedding_value)

        question_params = %{
          query: query,
          description: description,
          episodes: list_of_ids,
          embedding: embedding
        }

        changeset = Prompt.change_question(question, question_params)

        case Repo.insert(changeset) do
          {:ok, record} ->
            {
              :noreply,
              socket
              |> push_navigate(to: ~p"/chat/#{record.id}")
            }

          {:error, _changeset} ->
            {:noreply,
             socket
             |> put_flash(:error, "There was an error processing your request")}
        end

      false ->
        {:noreply, socket}
    end
  end
end
