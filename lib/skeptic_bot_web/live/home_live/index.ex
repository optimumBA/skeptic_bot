defmodule SkepticBotWeb.HomeLive.Index do
  @moduledoc """
  Our home page. Where a user submits his prompt
  """

  use SkepticBotWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="bg-[#FFF5F5]">
      <div class="flex items-start h-screen relative">
        <section>
          <div class="absolute top-[2.5rem] xl:top-[1rem] 3xl:top-[1.5rem] 4xl:top-[-1rem] left-0 w-[18%] xl:w-[21%] 2xl:w-[23%] 3xl:w-[21%]">
            <img src={~p"/images/home/top_swirl.svg"} class="w-full h-full object-cover" alt="Swirl" />
          </div>
          <div class="absolute bottom-[8rem] 2xl:bottom-[5rem] left-[4rem] w-[30%] 2xl:w-[33%]">
            <img src={~p"/images/home/demonstration.svg"} alt="Illustration 1" />
          </div>
          <div class="absolute bottom-[8rem] right-[2rem] w-[16%]">
            <img src={~p"/images/home/stars.png"} alt="Stars Group" />
          </div>
        </section>
        <section class="flex flex-col justify-start items-start gap-8 w-[70%] mx-auto">
          <section class="text-8xl mx-auto pt-32 xl:pt-36 2xl:pt-44 montserrat-semibold tracking-4">
            SKEPTIC.<span class="text-[#CD4631] montserrat-alternates-semibold">BOT</span>
          </section>
          <section class="w-[50%] mx-auto mt-6 text-center montserrat-alternates-medium text-[#4D4D4D]">
            Ask anything and get answers directly from trusted experts
          </section>
        </section>
      </div>
    </div>
    """
  end

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
