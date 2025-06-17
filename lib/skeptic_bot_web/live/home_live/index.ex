defmodule SkepticBotWeb.HomeLive.Index do
  use SkepticBotWeb, :live_view

  alias SkepticBot.Prompts
  alias SkepticBot.Rag.Embedder
  alias SkepticBotWeb.HomeLive.QuestionFormComponent

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
            <.live_component module={QuestionFormComponent} id="prompt form" />
          </section>
        </section>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :loading, false)}
  end

  @impl Phoenix.LiveView
  def handle_info({:generation_done, {description, list_of_episodes, query}}, socket) do
    {:ok, [embedding]} = Embedder.generate(query)

    episode_details = Prompts.get_episode_details(list_of_episodes)

    question_attrs = %{
      description: description,
      embedding: embedding,
      episodes: episode_details,
      query: query
    }

    case Prompts.create_question(question_attrs) do
      {:ok, question} ->
        send(self(), {:loading_state, false})

        {
          :noreply,
          push_navigate(socket, to: ~p"/questions/#{question.id}")
        }

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "There was an error processing your prompt")}
    end
  end

  @impl Phoenix.LiveView
  def handle_info({:loading_state, value}, socket) do
    {:noreply, assign(socket, :loading, value)}
  end

  @impl Phoenix.LiveView
  def handle_info(:no_episodes_found, socket) do
    {:noreply, put_flash(socket, :error, "No related podcast was found")}
  end
end
