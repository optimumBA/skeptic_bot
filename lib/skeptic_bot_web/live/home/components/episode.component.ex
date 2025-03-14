defmodule SkepticBotWeb.HomeLive.EpisodesComponent do
  use SkepticBotWeb, :live_component

  alias SkepticBot.Podcasts
  alias SkepticBotWeb.PodcastComponent

  alias SkepticBotWeb.Home.Component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div>
        <%= live_render(@socket, SkepticBotWeb.Header,
          id: "live_header",
          sticky: true
        ) %>
      </div>
      <section class="relative max-w-[33.6rem] text-center mx-auto mb-10">
        <p class="text-[#000000] text-title leading-none montserrat-alternates-bold">
          Who Killed John F Kennedy
        </p>
        <div class="superscript-question-2">
          <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
        </div>
      </section>

      <section class="max-w-[34rem] mx-auto  montserrat-alternates-medium text-[#4D4D4D] mb-10">
        The assassination of John F. Kennedy has given rise to numerous conspiracy theories, several of which are prominently discussed
      </section>

      <section class="max-w-[74%]  mx-auto  montserrat-alternates-bold text-[#000000] text-2xl">
        Related Podcasts
      </section>

      <section class="relative pb-16">
        <div class="flex justify-end">
          <section class="overflow-hidden pt-12 relative mb-12 w-[82rem]">
            <div
              class="flex gap-4 transition-transform duration-300 ease-in-out"
              style={"transform: translateX(-#{@related_episodes_index * 20.6875}rem);"}
            >
              <%= for episode <- @related_episodes do %>
                <PodcastComponent.podcast_video_card
                  image_file={episode.thumbnail}
                  podcast_title={first_two_words(episode.title)}
                  video_length={episode.video_length}
                  random={:rand.uniform(5)}
                />
              <% end %>
            </div>
          </section>
        </div>
        <div class="flex gap-5 max-w-[74%] mx-auto mt-16">
          <button
            phx-click="prev_related_episodes"
            phx-target={@myself}
            class="disabled:opacity-50"
            disabled={prev_btn_disabler(@related_episodes_index)}
          >
            <div>
              <img src={~p"/images/podcasts/back_arrow.svg"} alt="Back Arrow" />
            </div>
          </button>

          <button
            phx-click="next_related_episodes"
            phx-target={@myself}
            class="disabled:opacity-50"
            disabled={
              forward_btn_disabler(
                @related_episodes_index,
                @related_episodes
              )
            }
          >
            <div>
              <img src={~p"/images/podcasts/forward_arrow.svg"} alt="Forward Arrow" />
            </div>
          </button>
        </div>

        <div class="podcast-scribble">
          <img src={~p"/images/podcasts/podcast_scribble.svg"} alt="Podcast Scribble" />
        </div>
      </section>

      <section class="max-w-[74%] mx-auto  montserrat-alternates-bold text-[#000000] text-2xl">
        Other Podcasts
      </section>

      <section class="relative pb-16">
        <div class="flex justify-end">
          <section class="overflow-hidden pt-12 relative mb-12 w-[82rem]">
            <div
              class="flex gap-4 transition-transform duration-300 ease-in-out"
              style={"transform: translateX(-#{ @other_episodes_index * 20.6875}rem);"}
            >
              <%= for episode <- @other_episodes do %>
                <PodcastComponent.podcast_video_card
                  image_file={episode.thumbnail}
                  podcast_title={first_two_words(episode.title)}
                  video_length={episode.video_length}
                  random={:rand.uniform(5)}
                />
              <% end %>
            </div>
          </section>
        </div>

        <div class="flex gap-5 max-w-[74%] mx-auto mt-16">
          <button
            phx-click="prev_other_episodes"
            phx-target={@myself}
            class="disabled:opacity-50"
            disabled={prev_btn_disabler(@other_episodes_index)}
          >
            <div>
              <img src={~p"/images/podcasts/back_arrow.svg"} alt="Back Arrow" />
            </div>
          </button>

          <button
            phx-click="next_other_episodes"
            phx-target={@myself}
            class="disabled:opacity-50"
            disabled={
              forward_btn_disabler(
                @other_episodes_index,
                @other_episodes
              )
            }
          >
            <div>
              <img src={~p"/images/podcasts/forward_arrow.svg"} alt="Forward Arrow" />
            </div>
          </button>
        </div>
      </section>

      <section class="bg-[#FFF5F5] pt-28 pb-16">
        <section class="max-w-[76%] mx-auto pb-10 montserrat-alternates-bold text-[#000000] text-2xl">
          Related Questions
        </section>
        <section class="mx-auto max-w-[72rem]">
          <div class="podcast-questions-grid">
            <Component.card
              title="Covid-19 Actual Conspiracy"
              body="A nature survey shows many scientists expect the virus that causes COVID-19 to become"
              people_count="134"
              title_color="text-[#CD4631]"
            />
            <Component.card
              title="Tesla Autopilot Controversy"
              body="Tesla's vehicles boast 'Full-Self-Driving' (FSD), but current regulations do not allow for fully"
              people_count="134"
              title_color="text-[#000000]"
            />
            <Component.card
              title="Women's Rights? Is it alright?"
              body="A look back at history shows that women have made great strides in the fight for equality"
              people_count="134"
              title_color="text-[#000000]"
            />
            <Component.card
              title="Who Really Killed JKF?"
              body="We have a therapist expert as our guest, Krista Gordon is will share her experience"
              people_count="134"
              title_color="text-[#CD4631]"
            />
            <Component.card
              title="Epstein Controversy"
              body="Social class refers to a group of people with similar levels of wealth, influence, and"
              people_count="134"
              title_color="text-[#CD4631]"
            />
            <Component.card
              title="Are you a Perplexed mind Person?"
              body="Unable to grasp something clearly or to think logically and decisively about something"
              people_count="134"
              title_color="text-[#000000]"
            />
          </div>
        </section>
      </section>

      <section class="bg-[#ECF5FF] pt-28 pb-28">
        <section class="max-w-[76%] mx-auto pb-10 montserrat-alternates-bold text-[#000000] text-2xl">
          Other Podcasts
        </section>

        <div class="podcast-episodes-grid max-w-[72rem] mx-auto">
          <%= for episode <- @other_episodes do %>
            <PodcastComponent.podcast_video_grid_card
              image_file={episode.thumbnail}
              podcast_title={first_two_words(episode.title)}
              video_length={episode.video_length}
              random={:rand.uniform(3)}
            />
          <% end %>
        </div>
      </section>

      <Component.twitter_component />
    </div>
    """
  end

  @impl true

  def update(assigns, socket) do
    %{list_of_episodes: list_of_episodes} = assigns

    related_episodes = format_episodes(list_of_episodes)

    other_episodes =
      Podcasts.get_first_six_records()
      |> format_episodes()

    {:ok,
     socket
     |> assign(assigns)
     |> assign(related_episodes: related_episodes)
     |> assign(other_episodes: other_episodes)
     |> assign(other_episodes_index: 0)
     |> assign(related_episodes_index: 0)}
  end

  @impl true
  def handle_event("next_other_episodes", _params, socket) do
    index = socket.assigns.other_episodes_index
    episodes = socket.assigns.other_episodes
    new_index = min(index + 1, length(episodes) - 1)
    {:noreply, assign(socket, other_episodes_index: new_index)}
  end

  @impl true
  def handle_event("prev_other_episodes", _params, socket) do
    index = socket.assigns.other_episodes_index
    new_index = max(index - 1, 0)
    {:noreply, assign(socket, other_episodes_index: new_index)}
  end

  @impl true
  def handle_event("next_related_episodes", _params, socket) do
    index = socket.assigns.related_episodes_index
    episodes = socket.assigns.related_episodes
    new_index = min(index + 1, length(episodes) - 1)
    {:noreply, assign(socket, related_episodes_index: new_index)}
  end

  @impl true
  def handle_event("prev_related_episodes", _params, socket) do
    index = socket.assigns.related_episodes_index
    new_index = max(index - 1, 0)
    {:noreply, assign(socket, related_episodes_index: new_index)}
  end

  def format_episodes(episodes_list) do
    items =
      Enum.reduce(episodes_list, [], fn episode, output_list ->
        episode =
          case is_struct(episode) do
            true ->
              episode = Map.from_struct(episode)

              episode

            false ->
              episode
          end

        episode = Map.put(episode, :thumbnail, "cover1.svg")
        episode = Map.put(episode, :video_length, "02:20:45")
        [episode | output_list]
      end)

    items
  end

  def prev_btn_disabler(index) do
    # * called for the prev button
    if index == 0 do
      true
    else
      false
    end
  end

  def forward_btn_disabler(index, items) do
    # * called for the forward button
    if index >= length(items) - 1 do
      true
    else
      false
    end
  end

  defp first_two_words(string) do
    string
    |> String.split(~r/\s+/, trim: true)
    |> Enum.take(2)
    |> Enum.join(" ")
  end
end
