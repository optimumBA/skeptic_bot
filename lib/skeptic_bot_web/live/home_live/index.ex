defmodule SkepticBotWeb.HomeLive.Index do
  use SkepticBotWeb, :live_view

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="bg-[#FFF5F5]">
      <div class="flex items-center h-screen relative">
        <section>
          <div class="absolute top-[2%] left-0 2xl:top-[3%] w-[20%] xl:w-[22%] 2xl:w-[22%] 3xl:w-[21%] 4xl:w-[17%]">
            <img src={~p"/images/home/top_swirl.svg"} class="w-full h-full object-cover" alt="Swirl" />
          </div>
          <div class="absolute bottom-[20%] left-[4%] w-[20%] xl:w-[21%] 2xl:w-[22%] 3xl:w-[20%] 4xl:w-[17%]">
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
          <section class="text-7xl 2xl:text-8xl mx-auto montserrat-semibold tracking-4">
            Skeptic.<span class="text-[#CD4631] montserrat-alternates-semibold">bot</span>
          </section>
          <section class="w-[50%] mx-auto text-center montserrat-alternates-medium text-[#4D4D4D]">
            Questions everything
          </section>
        </section>
      </div>
    </div>
    """
  end
end
