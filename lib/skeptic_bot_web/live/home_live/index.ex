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
          <div class="absolute top-[2%] left-0 2xl:top-[3%] w-[22%] xl:w-[23%] 2xl:w-[22%] 3xl:w-[20%] 4xl:w-[17%]">
            <img src={~p"/images/home/top_swirl.svg"} class="w-full h-full object-cover" alt="Swirl" />
          </div>
          <div class="absolute bottom-[20%] left-[4%] w-[23%] xl:w-[21%] 2xl:w-[19%] 3xl:w-[17%]">
            <img
              src={~p"/images/home/demonstration.svg"}
              class="w-full h-full object-cover"
              alt="Illustration 1"
            />
          </div>
          <div class="absolute bottom-[10%] right-[1.3rem] w-[12%] 3xl:w-[10%]">
            <img
              src={~p"/images/home/stars.png"}
              class="w-full h-full object-cover"
              alt="Stars Group"
            />
          </div>
        </section>
        <section class="flex flex-col justify-start items-start gap-8 w-[70%] mx-auto mt-16">
          <section class="text-7xl 2xl:text-8xl mx-auto pt-32 2xl:pt-28 montserrat-semibold tracking-4">
            Skeptic.<span class="text-[#CD4631] montserrat-alternates-semibold">Bot</span>
          </section>
          <section class="w-[50%] mx-auto mt-6 text-center montserrat-alternates-medium text-[#4D4D4D]">
            Questions everything
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
