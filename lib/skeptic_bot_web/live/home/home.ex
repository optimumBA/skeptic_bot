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
          <section class="text-8xl pt-40 montserrat-semibold tracking-4">
            Your Daily <span class="text-[#CD4631] montserrat-alternates-semibold">Podcast</span>
          </section>

          <section class="w-[70%] flex flex-col items-start gap-8">
            <section class="w-[35%] ml-52 text-center montserrat-alternates-medium text-[#4D4D4D]">
              Ask anything and get answers directly from trusted experts
            </section>
            <section class="ml-28 w-[68%]">
              <.live_component module={SkepticBotWeb.HomeLive.FormComponent} id="prompt form" />
            </section>
            <section class="ml-44 mt-48 relative w-[68%]">
              <section class="text-6xl montserrat-alternates-bold text-[#000000]">
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
        <section class="relative max-w-[41.8rem] text-center mx-auto">
          <p class="text-[#000000] text-title leading-none montserrat-alternates-bold">
            Questions that fuel insight and curiosity
          </p>
          <div class="superscript-question">
            <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
          </div>
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

      <div class="relative bg-[#FFF5F5] py-20">
        <section class="relative max-w-[38.813rem] text-center mx-auto">
          <p class="font-bold text-[#000000] text-title leading-none">
            Insightful clips to expand your view
            <div class="superscript-question">
              <img src={~p"/images/home/top_letter.svg"} alt="Superscript Image Question" />
            </div>
          </p>
        </section>

        <section class="max-w-[73.6rem] py-20 mx-auto">
          <div class="clips-grid">
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
        <section class="bottom-vector w-80">
          <img src={~p"/images/home/bottom_vector.svg"} alt="Bottom Vector" class="object-cover" />
        </section>
      </div>

      <div class="pt-10 pb-4">
        <div class="divider bg-[#7F7F7F] w-[92%] mx-auto">
          &zwj;
        </div>

        <.link href="https://x.com/optimumBA">
          <div class="w-[10%] mx-auto border border-[#532822] rounded-custom my-8">
            <section class="py-3 w-[98%] mx-auto flex gap-2 justify-center items-center">
              <div>
                <img src={~p"/images/home/twitter.svg"} alt="Twitter Icon" />
              </div>
              <div class="text-[#532822] text-lg font-bold">Twitter</div>
            </section>
          </div>
        </.link>
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
