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
    <div class={[
      "bg-[#FFF5F5]",
      @loading && "bg-[#FFFFFF]"
    ]}>
      <div class="h-screen flex items-center relative">
        <section class="pt-20 md:pt-0">
          <div class={[
            "absolute top-[2%] left-0 w-[38%] xl:top-[1rem] xs:w-[30%] 2xs:w-[34%] md:w-[25%] lg:w-[18%] xl:w-[14rem] z-30",
            @loading && "hidden"
          ]}>
            <img src={~p"/images/home/top_swirl.svg"} class="w-full h-full object-cover" alt="Swirl" />
          </div>
          <div class={[
            "absolute bottom-[16%] 2xs:bottom-[13%] sm:bottom-[10%] md:bottom-[11%] 2md:bottom-[8%] xl:bottom-auto xl:top-[12rem] left-[4%] xl:left-[2.8rem] w-[34%] xs:w-[30%] 2xs:w-[27%] md:w-[20%] xl:w-[15rem]",
            @loading && "hidden"
          ]}>
            <img
              src={~p"/images/home/demonstration.svg"}
              class="w-full h-full object-cover"
              alt="Illustration 1"
            />
          </div>

          <div class={[
            "absolute bottom-[8%] 2xs:bottom-[6%] md:bottom-[9%] right-[1.3rem] w-[24%] xs:w-[18%] 2xs:w-[18%] md:w-[10%]",
            @loading && "hidden"
          ]}>
            <img
              src={~p"/images/home/hero_stars.svg"}
              class="w-full h-full object-cover"
              alt="Stars Group"
            />
          </div>
        </section>
        <section class="flex flex-col gap-8 w-[93%] md:w-[70%] mx-auto">
          <section class="text-6xl mx-auto montserrat-bold tracking-4 md:text-7xl 2xl:text-8xl">
            Skeptic.<span class="text-[#CD4631] montserrat-alternates-bold">bot</span>
          </section>
          <div class={[
            @loading && "hidden"
          ]}>
            <section class="w-[50%] mx-auto text-center montserrat-alternates-medium text-[#4D4D4D] mb-10">
              Questions everything
            </section>

            <section class="w-full mx-auto xs:w-[95%] 2xs:w-[80%] sm:w-[80%] md:w-[96%] lg:w-[80%] xl:w-[60%]">
              <HomeLive.Components.form_component form={@form} />
            </section>
          </div>

          <div class={[
            "w-[80%] mx-auto",
            !@loading && "hidden"
          ]}>
            <section class="text-center montserrat-alternates-semibold text-[#4D4D4D] mb-6">
              is almost done second guessing
            </section>
            <section>
              <HomeLive.Components.loading_component />
            </section>
          </div>
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

    {:noreply,
     socket
     |> assign(:query, query)
     |> maybe_generate_prompt_results(changeset.valid?)}
  end

  defp maybe_generate_prompt_results(socket, false), do: socket

  defp maybe_generate_prompt_results(%{assigns: %{query: query}} = socket, true) do
    send(self(), {:loading_state, true})

    start_async(socket, :prompt_results, fn ->
      Rag.generate(query)
    end)
  end

  @impl Phoenix.LiveView
  def handle_async(:prompt_results, {:ok, prompt_results}, socket) do
    case prompt_results do
      {:ok, {response, podcast_episodes, embedding}} ->
        handle_prompt_results(response, podcast_episodes, embedding, socket)

      {:error, :no_episodes_found} ->
        send(self(), {:loading_state, false})

        {:noreply,
         put_flash(socket, :error, "Sorry, we currently have no podcasts discussing this topic.")}

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

  defp handle_prompt_results(
         response,
         podcast_episodes,
         embedding,
         %{assigns: %{query: query}} = socket
       ) do
    with episode_details <- Prompts.get_episode_details(podcast_episodes),
         {title, description} <- get_title_and_description(response),
         question_attrs <- %{
           description: description,
           embedding: embedding,
           episodes: episode_details,
           query: query,
           title: title
         },
         {:ok, question} <- Prompts.create_question(question_attrs) do
      {:noreply, push_navigate(socket, to: "/questions/#{question.id}")}
    else
      {:error, reason} ->
        Logger.error("Question creation failed. Reason: #{inspect(reason)}")
        send(self(), {:loading_state, false})
        {:noreply, put_flash(socket, :error, "There was an error processing your prompt")}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:loading_state, value}, socket) do
    {:noreply, assign(socket, :loading, value)}
  end

  defp assign_form(%{assigns: %{question: question}} = socket) do
    form =
      question
      |> Prompts.change_question_query()
      |> to_form()

    assign(socket, :form, form)
  end

  defp get_title_and_description(response) do
    case Jason.decode(response) do
      {:ok, %{"description" => description, "title" => title}} ->
        {title, description}

      {:error, error} ->
        {:error, error}
    end
  end
end
