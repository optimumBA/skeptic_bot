defmodule SkepticBotWeb.HomeLive.Components do
  @moduledoc """
  Holds our form
  """

  use SkepticBotWeb, :html

  @type assigns :: map()
  @type rendered :: Phoenix.LiveView.Rendered.t()

  attr :form, :map, required: true

  @spec form_component(assigns()) :: rendered()
  def form_component(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-change="validate" phx-submit="save" id="question-input-form">
        <div class="flex justify-between md:mt-8 items-center rounded-xl hover:cursor-pointer form-input-shadow border bg-[#FFFFFF] md:py-2 gap-2">
          <div class="w-2/3 grow pl-4">
            <.input
              class="montserrat-alternates-medium placeholder:text-sm w-full border-none bg-[#FFFFFF] outline-none rounded-lg py-[3px] px-[11px] remove-outline placeholder:text-[#4D4D4D] sm:text-lg sm:leading-6"
              placeholder="Ask anything"
              field={@form[:query]}
              autocomplete="off"
              phx-debounce="1000"
            />
          </div>

          <.button
            type="submit"
            class="hover:cursor-pointer text-[#FFFFFF] bg-[#CD4631] transition ease-in-out duration-300 my-3 mr-4"
          >
            <div class="flex flex-row gap-2 items-center">
              <div class="pl-0 md:pl-2">
                <img src={~p"/images/home/search_icon.svg"} alt="Search Icon" />
              </div>

              <section class="hidden md:block montserrat-alternates-medium">Search...</section>
            </div>
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  @spec loading_component(assigns()) :: rendered()
  def loading_component(assigns) do
    ~H"""
    <div class={[
      "flex items-center justify-center space-x-1"
    ]}>
      <.dot_component animation_delay="delay-0" />
      <.dot_component animation_delay="delay-200" />
      <.dot_component animation_delay="delay-400" />
    </div>
    """
  end

  attr :animation_delay, :string, required: true

  @spec dot_component(assigns()) :: rendered()
  def dot_component(assigns) do
    ~H"""
    <img
      src={~p"/images/home/typing_dot.svg"}
      class={[
        "object-cover dot-animation",
        @animation_delay
      ]}
      alt="Typing Dot"
    />
    """
  end
end
