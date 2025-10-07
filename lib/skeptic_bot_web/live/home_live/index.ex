defmodule SkepticBotWeb.HomeLive.Index do
  use SkepticBotWeb, :live_view

  alias SkepticBot.Podcasts
  alias SkepticBot.PredictionHandler
  alias SkepticBot.Prompts
  alias SkepticBot.Prompts.UserQuestion
  alias SkepticBot.Rag
  alias SkepticBotWeb.HomeLive
  alias SkepticBotWeb.PodcastComponents

  @episode_limit 6
  @vector_numbers [1, 2, 3, 4, 5]

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash}>
      <div class={[
        "bg-[#FFF5F5]",
        @loading && "bg-[#FFFFFF]"
      ]}>
        <div class="flex relative">
          <section>
            <div class={[
              "w-[8rem] absolute top-[-4rem] left-[-2rem] z-30 xs:w-[9rem] md:w-[11rem] md:top-[-7rem] lg:w-[12rem] xl:top-[-2rem] xl:left-0",
              @loading && "hidden"
            ]}>
              <img
                src={~p"/images/home/top_swirl.svg"}
                class="w-full h-full object-cover"
                alt="Swirl"
              />
            </div>
            <div class={[
              "w-[7rem] absolute top-[2rem] left-[0.8rem] xs:w-[8rem] xs:top-[2.8rem] md:w-[10rem] md:top-[1.8rem] lg:left-[1.2rem] lg:w-[12rem] lg:top-[2rem] xl:w-[13rem] xl:top-[7.4rem] xl:left-[2.2rem]",
              @loading && "hidden"
            ]}>
              <img
                src={~p"/images/home/demonstration.svg"}
                class="w-full h-full object-cover"
                alt="Illustration 1"
              />
            </div>

            <div class={[
              "w-[3rem] absolute top-[8%] right-[1rem] 2xs:w-[4rem] md:w-[5rem] md:top-[15%] 2md:top-[28%]",
              @loading && "hidden"
            ]}>
              <img
                src={~p"/images/home/hero_stars.svg"}
                class="w-full h-full object-cover"
                alt="Stars Group"
              />
            </div>
          </section>
          <section class="w-full mt-36">
            <section class="w-[93%] mx-auto flex flex-col gap-4 md:w-[70%]">
              <section class="text-6xl mx-auto montserrat-alternates-bold tracking-4 md:text-7xl 2xl:text-8xl">
                Skeptic.<span class="text-primary montserrat-alternates-bold">bot</span>
              </section>
              <div class={[
                @loading && "hidden"
              ]}>
                <section class="w-[50%] mb-6 mx-auto text-secondary text-center">
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

            <section class={[
              "latest-podcast-gradient",
              @loading && "hidden"
            ]}>
              <section class="max-content-width mx-auto mt-4 pt-8">
                <PodcastComponents.episode_card_carousel
                  episode_vectors={@latest_episodes_vectors}
                  episodes={@latest_episodes}
                  icon_path={~p"/images/home/latest_podcast_icon.svg"}
                  title="Latest Podcasts"
                />
              </section>
            </section>
          </section>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    latest_episodes = Podcasts.get_latest_episodes(3)

    latest_episodes_vectors =
      @vector_numbers
      |> Enum.shuffle()
      |> Stream.cycle()
      |> Enum.take(@episode_limit)

    {:ok,
     socket
     |> assign(:latest_episodes, latest_episodes)
     |> assign(:latest_episodes_vectors, latest_episodes_vectors)
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
