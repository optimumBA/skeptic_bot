defmodule SkepticBotWeb.HomeLive.Show do
  @moduledoc """
  The Response Page.
  """

  use SkepticBotWeb, :live_view

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

      <section class="max-w-[74%] mx-auto  montserrat-alternates-bold text-[#000000] text-2xl">
        Related Podcast
      </section>

      <section class="relative pb-16">
        <div class="flex justify-end">
          <section class="overflow-hidden pt-12 relative mb-12 max-w-[82rem]">
            <div
              class="flex gap-4 transition-transform duration-300 ease-in-out"
              style={"transform: translateX(-#{@index * 20.6875}rem);"}
            >
              <%= for item <- @items do %>
                <PodcastComponent.podcast_video_card
                  image_file={item.thumbnail}
                  podcast_title={item.podcast_title}
                  video_length={item.video_length}
                  random={:rand.uniform(5)}
                />
              <% end %>
            </div>
          </section>
        </div>

        <div class="flex gap-5 max-w-[74%] mx-auto mt-16">
          <button phx-click="prev" class="disabled:opacity-50" disabled={prev_btn_disabler(@index)}>
            <div>
              <img src={~p"/images/podcasts/back_arrow.svg"} alt="Back Arrow" />
            </div>
          </button>

          <button
            phx-click="next"
            class="disabled:opacity-50"
            disabled={
              forward_btn_disabler(
                @index,
                @items
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
        Top Podcast
      </section>

      <section class="relative pb-16">
        <div class="flex justify-end">
          <section class="overflow-hidden pt-12 relative mb-12 max-w-[82rem]">
            <div
              class="flex gap-4 transition-transform duration-300 ease-in-out"
              style={"transform: translateX(-#{@index * 20.6875}rem);"}
            >
              <%= for item <- @items do %>
                <PodcastComponent.podcast_video_card
                  image_file={item.thumbnail}
                  podcast_title={item.podcast_title}
                  video_length={item.video_length}
                  random={:rand.uniform(5)}
                />
              <% end %>
            </div>
          </section>
        </div>

        <div class="flex gap-5 max-w-[74%] mx-auto mt-16">
          <button phx-click="prev" class="disabled:opacity-50" disabled={prev_btn_disabler(@index)}>
            <div>
              <img src={~p"/images/podcasts/back_arrow.svg"} alt="Back Arrow" />
            </div>
          </button>

          <button
            phx-click="next"
            class="disabled:opacity-50"
            disabled={
              forward_btn_disabler(
                @index,
                @items
              )
            }
          >
            <div>
              <img src={~p"/images/podcasts/forward_arrow.svg"} alt="Forward Arrow" />
            </div>
          </button>
        </div>
      </section>

      <section class="mx-auto mb-32 max-w-[72rem]">
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
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(items: get_items())
     |> assign(index: 0)}
  end

  @impl true
  def handle_params(%{"id" => _id}, _url, socket) do
    # dbg(id)
    {:noreply, socket}
  end

  @impl true
  def handle_event("next", _, socket) do
    new_index = min(socket.assigns.index + 1, length(socket.assigns.items) - 1)
    {:noreply, assign(socket, index: new_index)}
  end

  @impl true
  def handle_event("prev", _, socket) do
    new_index = max(socket.assigns.index - 1, 0)
    {:noreply, assign(socket, index: new_index)}
  end

  def get_items() do
    [
      %{
        thumbnail: "cover1.svg",
        podcast_title: "JFK Assassination",
        video_length: "02:20:45"
      },
      %{
        thumbnail: "cover2.svg",
        podcast_title: "Space X",
        video_length: "02:41:45"
      },
      %{
        thumbnail: "cover3.svg",
        podcast_title: "Trump's Rule",
        video_length: "03:31:45"
      },
      %{
        thumbnail: "cover4.svg",
        podcast_title: "Kenya Chaos",
        video_length: "04:31:45"
      },
      %{
        thumbnail: "cover5.svg",
        podcast_title: "Nigerian Delta",
        video_length: "02:31:35"
      },
      %{
        thumbnail: "cover1.svg",
        podcast_title: "Women's Rights",
        video_length: "02:53:45"
      },
      %{
        thumbnail: "cover2.svg",
        podcast_title: "USAID Crisis",
        video_length: "10:36:45"
      },
      %{
        thumbnail: "cover3.svg",
        podcast_title: "Femicide",
        video_length: "02:21:45"
      }
    ]
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
end
