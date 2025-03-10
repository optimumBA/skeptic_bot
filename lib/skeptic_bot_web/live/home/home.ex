defmodule SkepticBotWeb.HomeLive.Index do
  @moduledoc """
  The home page containing the chat input.
  """

  use SkepticBotWeb, :live_view

  alias SkepticBotWeb.Home.Component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <div class="bg-[#FFF5F5]">
        <%= live_render(@socket, SkepticBotWeb.Header,
          id: "live_header",
          sticky: true
        ) %>
      </div>

      <div class="flex justify-start items-start gap-20 h-screen bg-[#FFF5F5]">
        <section>
          <div class="top-swirl"><img src={~p"/images/home/top_swirl.svg"} alt="Swirl" /></div>
          <div class="illustration w-[20%]">
            <img src={~p"/images/home/illustration_1.svg"} alt="Illustration 1" />
          </div>

          <div class="stars w-[11%]">
            <img src={~p"/images/home/stars.png"} alt="Stars Group" />
          </div>
        </section>
        <section class="flex flex-col justify-start items-start pl-72 gap-8 w-full">
          <section class="text-8xl pt-40">
            Your Daily <span class="text-[#CD4631]">Podcast</span>
          </section>

          <section class="w-[70%] flex flex-col items-start gap-8">
            <section class="w-[35%] ml-52 text-center">
              Ask anything and get answers directly from trusted experts
            </section>
            <section class="ml-28 w-[68%]">
              <.live_component module={SkepticBotWeb.HomeLive.FormComponent} id="prompt form" />
            </section>
            <section class="ml-44 mt-48 relative w-[68%]">
              <section class="text-6xl">
                Popular Podcast
              </section>

              <div class="superscript-image">
                <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image" />
              </div>
            </section>
          </section>
        </section>
      </div>

      <Component.pictures />

      <div class="my-20">
        <section class="relative max-w-[38.813rem] text-center mx-auto">
          <p class="font-bold text-[#000000] text-title leading-none">
            Questions that fuel insight and curiosity
            <div class="superscript-question">
              <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
            </div>
          </p>
        </section>
        <section class="relative mx-auto mb-32 max-60">
          <div class="questions-grid">
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
          <img src={~p"/images/cards/scribble.svg"} alt="Scribble" class="scribble" />
        </section>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
