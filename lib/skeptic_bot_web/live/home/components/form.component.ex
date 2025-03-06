defmodule SkepticBotWeb.HomeLive.FormComponent do
  @moduledoc """
  Our form component.

  Forwads the user Prompt to the LLM.
  """

  use SkepticBotWeb, :live_component

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-target={@myself} phx-submit="save">
        <div class="flex justify-between mt-8 items-center rounded-xl hover:cursor-pointer custom-shadow border">
          <div class="w-2/3 grow pl-4">
            <.input placeholder="Ask anything" field={@form[:query]} autocomplete="off" />
          </div>

          <.button
            type="submit"
            phx-disable-with="Searching..."
            class="hover:cursor-pointer text-[#FFFFFF] bg-[#CD4631] transition ease-in-out duration-300 my-3 mr-4"
          >
            <div class="flex flex-row gap-2 items-center">
              <div class="pl-2">
                <img src={~p"/images/home/search_icon.svg"} alt="Search Icon" />
              </div>

              <section>Search...</section>
            </div>
          </.button>
        </div>
      </.form>
    </div>
    """
  end

  @impl true

  def update(assigns, socket) do
    form = to_form(%{}, as: "prompt")

    {:ok,
     socket
     |> assign(assigns)
     |> assign(form: form)}
  end

  @impl true
  def handle_event("save", %{"prompt" => %{"query" => prompt_params}}, socket) do
    dbg(prompt_params)

    {:noreply, socket}
  end
end
