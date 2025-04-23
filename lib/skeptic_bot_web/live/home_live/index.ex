defmodule SkepticBotWeb.HomeLive.Index do
  @moduledoc """
  Our home page. Where a user submits his prompt
  """

  use SkepticBotWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div>
      <div class="lg:h-screen">
        <div class="bg-[#FFF5F5]">
          <%= live_render(@socket, SkepticBotWeb.HeaderLive,
            id: "live_header",
            sticky: true
          ) %>
        </div>
        <div class="flex justify-start items-start gap-20  bg-[#FFF5F5] pb-16 relative">
          <section>
            <div class="absolute top-[-8rem] left-0 w-[20%] pointer-events-none">
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
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
