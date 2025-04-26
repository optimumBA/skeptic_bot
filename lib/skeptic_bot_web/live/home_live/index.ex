defmodule SkepticBotWeb.HomeLive.Index do
  use SkepticBotWeb, :live_view

  alias SkepticBot.Repo
  alias SkepticBotWeb.HomeLive.QuestionFormComponent
  alias SkepticBotWeb.PromptHelpers

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="bg-[#FFF5F5]">
      <div class="h-screen flex items-center relative">
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
  def handle_info({:generation_done, {description, list_of_episodes}, {query, question}}, socket) do
    changeset =
      PromptHelpers.return_question_changeset(list_of_episodes, query, description, question)

    case Repo.insert(changeset) do
      {:ok, record} ->
        {
          :noreply,
          push_navigate(socket, to: ~p"/podcasts/#{record.id}")
        }

      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "There was an error processing your request")}
    end
  end
end
