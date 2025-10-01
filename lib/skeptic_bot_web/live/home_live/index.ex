defmodule SkepticBotWeb.HomeLive.Index do
  use SkepticBotWeb, :live_view

  alias SkepticBot.PredictionHandler
  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBot.Rag
  alias SkepticBotWeb.HomeLive

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class={[
        "bg-[#FFF5F5]",
        @loading && "bg-[#FFFFFF]"
      ]}>
        <div class="h-screen flex items-center relative">
          <section class="pt-20 md:pt-0">
            <div class={[
              "w-[38%] absolute top-[2%] left-0 z-30 xs:w-[30%] 2xs:w-[34%] md:w-[25%] lg:w-[18%] xl:w-[14rem] xl:top-[1rem]",
              @loading && "hidden"
            ]}>
              <img
                src={~p"/images/home/top_swirl.svg"}
                class="w-full h-full object-cover"
                alt="Swirl"
              />
            </div>
            <div class={[
              "w-[34%] absolute bottom-[16%] left-[4%] xs:w-[30%] 2xs:w-[27%] 2xs:bottom-[13%] sm:bottom-[10%] md:w-[20%] md:bottom-[11%] 2md:bottom-[8%] xl:w-[15rem] xl:bottom-auto xl:top-[12rem] xl:left-[2.8rem]",
              @loading && "hidden"
            ]}>
              <img
                src={~p"/images/home/demonstration.svg"}
                class="w-full h-full object-cover"
                alt="Illustration 1"
              />
            </div>

            <div class={[
              "w-[24%] absolute bottom-[8%] right-[1.3rem] xs:w-[18%] 2xs:w-[18%] 2xs:bottom-[6%] md:w-[10%] md:bottom-[9%]",
              @loading && "hidden"
            ]}>
              <img
                src={~p"/images/home/hero_stars.svg"}
                class="w-full h-full object-cover"
                alt="Stars Group"
              />
            </div>
          </section>
          <section class="w-[93%] mx-auto flex flex-col gap-8 md:w-[70%]">
            <section class="text-6xl mx-auto montserrat-alternates-bold tracking-4 md:text-7xl 2xl:text-8xl">
              Skeptic.<span class="text-primary montserrat-alternates-bold">bot</span>
            </section>
            <div class={[
              @loading && "hidden"
            ]}>
              <section class="w-[50%] mb-10 mx-auto text-secondary text-center">
                Questions everything
              </section>

              <section class="w-full mx-auto xs:w-[95%] 2xs:w-[80%] sm:w-[80%] md:w-[96%] lg:w-[80%] xl:w-[60%]">
                <HomeLive.Components.form_component form={@form} />
              </section>
            </div>

            <div
              id="loading-elements"
              class={[
                "w-[80%] mx-auto",
                !@loading && "hidden"
              ]}
            >
              <section class="text-secondary text-center montserrat-alternates-semibold mb-6">
                is almost done second guessing
              </section>
              <section>
                <HomeLive.Components.loading_component />
              </section>
            </div>
          </section>
        </div>
      </div>
    </Layouts.app>
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
      Rag.generate_embedding(query)
    end)
  end

  @impl Phoenix.LiveView
  def handle_async(:prompt_results, {:ok, prompt_results}, socket) do
    case prompt_results do
      {:ok, {podcast_episodes, embedding}} ->
        handle_prompt_results(podcast_episodes, embedding, socket)

      {:error, :no_episodes_found} ->
        send(self(), {:loading_state, false})

        {:noreply,
         put_flash(socket, :error, "Sorry, we currently have no podcasts discussing this topic.")}

      {:error, _reason} ->
        send(self(), {:loading_state, false})

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
         podcast_episodes,
         embedding,
         %{assigns: %{query: query}} = socket
       ) do
    episode_details = Prompts.get_episode_details(podcast_episodes)

    question_attrs = %{
      embedding: embedding,
      episodes: episode_details,
      query: query
    }

    {:ok, question} = Prompts.create_question(question_attrs)

    :ok = PredictionHandler.make_llm_request(podcast_episodes, question)

    {:noreply, push_navigate(socket, to: ~p"/questions/#{question.id}")}
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
end
