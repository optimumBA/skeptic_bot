defmodule SkepticBotWeb.HomeLive.Index do
  use SkepticBotWeb, :live_view

  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBot.Rag
  alias SkepticBotWeb.HomeLive

  require Logger

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="bg-[#FFF5F5]">
      <div class={[
        "h-screen flex items-center relative",
        @loading && "animate-pulse"
      ]}>
        <section>
          <div class="absolute top-[2%] left-0 w-[20%] 2xl:top-[3%] 4xl:w-[17%]">
            <img src={~p"/images/home/top_swirl.svg"} class="w-full h-full object-cover" alt="Swirl" />
          </div>
          <div class="absolute bottom-[20%] left-[4%] w-[20%] xl:w-[21%] 2xl:w-[20%] 4xl:w-[17%]">
            <img
              src={~p"/images/home/demonstration.svg"}
              class="w-full h-full object-cover"
              alt="Illustration 1"
            />
          </div>
          <div class="absolute bottom-[10%] right-[1.3rem] w-[10%]">
            <img
              src={~p"/images/home/hero_stars.svg"}
              class="w-full h-full object-cover"
              alt="Stars Group"
            />
          </div>
        </section>
        <section class="flex flex-col gap-8 w-[70%] mx-auto">
          <section class="text-7xl mx-auto montserrat-semibold tracking-4 2xl:text-8xl">
            Skeptic.<span class="text-[#CD4631] montserrat-alternates-semibold">bot</span>
          </section>
          <section class="w-[50%] mx-auto text-center montserrat-alternates-medium text-[#4D4D4D]">
            Questions everything
          </section>
          <section class="w-[60%] mx-auto">
            <HomeLive.Components.form_component form={@form} />
          </section>
        </section>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:loading, false)
     |> assign(:question, %UserQuestion{})
     |> assign_form()}
  end

  @impl Phoenix.LiveView
  def handle_event(
        "validate",
        %{"user_question" => question_params},
        %{assigns: %{question: question}} = socket
      ) do
    changeset =
      question
      |> Prompts.change_question_query(question_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :form, to_form(changeset))}
  end

  def handle_event(
        "save",
        %{"user_question" => %{"query" => query} = question_params},
        %{assigns: %{question: question}} = socket
      ) do
    changeset =
      Prompts.change_question_query(question, question_params)

    socket = assign(socket, :query, query)

    {:noreply, maybe_generate_prompt_results(changeset.valid?, socket)}
  end

  defp maybe_generate_prompt_results(false, socket), do: socket

  defp maybe_generate_prompt_results(true, %{assigns: %{query: query}} = socket) do
    send(self(), {:loading_state, true})

    start_async(socket, :prompt_results, fn ->
      Rag.generate(query)
    end)
  end

  @impl Phoenix.LiveView
  def handle_async(:prompt_results, {:ok, prompt_results}, socket) do
    case prompt_results do
      {:ok, {description, podcast_episodes}} ->
        handle_prompt_results(description, podcast_episodes, socket)

      {:error, _reason} ->
        {:noreply,
         put_flash(
           socket,
           :error,
           "An error occurred while processing your prompt. Please try again."
         )}
    end
  end

  def handle_async(:prompt_results, {:exit, _reason}, socket) do
    send(self(), {:loading_state, false})

    {:noreply,
     put_flash(
       socket,
       :error,
       "An error occurred while processing your prompt. Please try again."
     )}
  end

  defp handle_prompt_results(description, podcast_episodes, %{assigns: %{query: query}} = socket) do
    with {:ok, [embedding]} <- Rag.Embedder.generate(query),
         episode_details <- Prompts.get_episode_details(podcast_episodes),
         question_attrs <- %{
           description: description,
           embedding: embedding,
           episodes: episode_details,
           query: query
         },
         {:ok, question} <- Prompts.create_question(question_attrs) do
      {:noreply, push_navigate(socket, to: "/questions/#{question.id}")}
    else
      {:error, reason} ->
        send(self(), {:loading_state, false})
        Logger.error("Failed to create a question with reason: #{reason}")
        {:noreply, put_flash(socket, :error, "There was an error processing your prompt")}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:loading_state, value}, socket) do
    {:noreply, assign(socket, :loading, value)}
  end

  defp assign_form(%{assigns: %{question: question}} = socket) do
    assign(socket, :form, to_form(Prompts.change_question_query(question)))
  end
end
