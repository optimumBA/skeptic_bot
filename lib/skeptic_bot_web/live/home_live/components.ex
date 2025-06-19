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
      <.form for={@form} phx-change="validate" phx-submit="save" id="prompt-input-form">
        <div class="flex justify-between mt-8 items-center rounded-xl hover:cursor-pointer form-input-shadow border bg-[#FFFFFF] py-2">
          <div class="w-2/3 grow pl-4">
            <.input
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
              <div class="pl-2">
                <img src={~p"/images/home/search_icon.svg"} alt="Search Icon" />
              </div>

              <section class="montserrat-alternates-medium">Search...</section>
            </div>
          </.button>
        </div>
      </.form>
    </div>
    """
  end
end
