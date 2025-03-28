defmodule SkepticBotWeb.HomeLive.Index do
  @moduledoc """
  The home page containing the chat input.
  """

  use SkepticBotWeb, :live_view

  alias SkepticBotWeb.Home.Component

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <div class="h-screen">
        <div class="bg-[#FFF5F5]">
          <%= live_render(@socket, SkepticBotWeb.Header,
            id: "live_header",
            sticky: true
          ) %>
        </div>
        <div class="flex justify-start items-start gap-20  bg-[#FFF5F5] pb-16 relative">
          <section>
            <div class="absolute top-[-8rem] left-0 w-[20%]">
              <img
                src={~p"/images/home/top_swirl.svg"}
                class="w-full h-full object-cover"
                alt="Swirl"
              />
            </div>
            <div class="absolute  top-[16rem] left-[4rem] w-[20%]">
              <img src={~p"/images/home/illustration_1.svg"} alt="Illustration 1" />
            </div>
            <div class="absolute bottom-[7rem] right-[2rem] w-[11%]">
              <img src={~p"/images/home/stars.png"} alt="Stars Group" />
            </div>
          </section>
          <section class="flex flex-col justify-start items-start gap-8 w-full">
            <section class="text-8xl mx-auto pt-14 montserrat-semibold tracking-4">
              Your Daily <span class="text-[#CD4631] montserrat-alternates-semibold">Podcast</span>
            </section>
            <section class="w-[70%] mx-auto mt-6 flex flex-col items-start gap-8">
              <section class="w-[35%] ml-[20rem] text-center montserrat-alternates-medium text-[#4D4D4D]">
                Ask anything and get answers directly from trusted experts
              </section>
              <section class="ml-32 pl-10 mt-4 w-[70%]">
                <.live_component module={SkepticBotWeb.HomeLive.FormComponent} id="prompt form" />
              </section>
              <section class="ml-56 mt-36 relative w-[68%]">
                <section class="text-6xl montserrat-alternates-bold text-[#000000]">
                  Popular Podcast
                </section>
                <div class="absolute top-[-2.5rem] left-[-3rem]">
                  <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image" />
                </div>
              </section>
            </section>
          </section>
        </div>
      </div>

      <Component.pictures />

      <div class="my-20">
        <section class="relative max-w-[41.8rem] text-center mx-auto">
          <p class="text-[#000000] text-title leading-none montserrat-alternates-bold">
            Questions that fuel insight and curiosity
          </p>
          <div class="absolute top-[-2.1rem] left-[-0.4rem]">
            <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
          </div>
        </section>
        <section class="relative mx-auto mb-32 max-w-[61rem]">
          <div class="grid grid-cols-2 gap-[0.8rem]">
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
          <img
            src={~p"/images/cards/scribble.svg"}
            alt="Scribble"
            class="absolute bottom-[-11.9rem] left-[-11rem]"
          />
        </section>
      </div>

      <div class="relative bg-[#FFF5F5] py-16 pb-40">
        <section class="relative max-w-[38.813rem] text-center mx-auto">
          <p class="text-[#000000] text-title leading-none montserrat-alternates-bold">
            Insightful clips to expand your view
            <div class="absolute top-[-2.1rem] left-[-0.4rem]">
              <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
            </div>

            <div class="absolute top-[-8rem] left-[13.6rem]">
              <img src={~p"/images/clips/scribble2.svg"} alt="Scribble 2" />
            </div>
          </p>
        </section>

        <section class="max-w-[75.6rem] py-20 mx-auto">
          <div class="grid grid-cols-3 gap-[1rem]">
            <Component.clip
              image_file="clip1.svg"
              title="Quarter-life crisis"
              author="Allen John"
              video_length="23:20"
            />

            <Component.clip
              image_file="clip2.svg"
              title="Finance Gen Ƶ"
              author="Brock Leslar"
              video_length="45:00"
            />

            <Component.clip
              image_file="clip3.svg"
              title="Love, Family, and Secrets"
              author="Aidan & Friends"
              video_length="16:20"
            />
          </div>
        </section>
        <section class="absolute top-[7.8rem] right-0 w-[26.2%]">
          <img
            src={~p"/images/home/bottom_vector.svg"}
            alt="Bottom Vector"
            class="w-[100%] h-[100%] object-cover"
          />
        </section>
      </div>

      <Component.twitter_component />
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
