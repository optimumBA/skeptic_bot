defmodule SkepticBotWeb.HomeLive.FormComponent do
  @moduledoc """
  Our form component.

  Forwads the user Prompt to the LLM.
  """

  use SkepticBotWeb, :live_component

  alias SkepticBot.{Query, Prompt}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.form for={@form} phx-target={@myself} phx-change="validate" phx-submit="save">
        <div class="flex justify-between mt-8 items-center rounded-xl hover:cursor-pointer custom-shadow border">
          <div class="w-2/3 grow pl-4">
            <.input
              placeholder="Ask anything"
              field={@form[:query]}
              autocomplete="off"
              phx-debounce="500"
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
    {:ok,
     socket
     |> assign(assigns)
     |> assign(:prompt, %Prompt{})
     |> assign_form()}
  end

  def assign_form(%{assigns: %{prompt: prompt}} = socket) do
    socket
    |> assign(:form, to_form(Query.change_prompt(prompt), as: "prompt"))
  end

  @impl true
  def handle_event(
        "validate",
        %{"prompt" => prompt_params},
        %{assigns: %{prompt: prompt}} = socket
      ) do
    changeset =
      prompt
      |> Query.change_prompt(prompt_params)
      |> Map.put(:action, :validate)

    {:noreply,
     socket
     |> assign(:form, to_form(changeset, as: "prompt"))}
  end

  @impl true
  def handle_event(
        "save",
        %{"prompt" => _prompt_params},
        %{assigns: %{form: form}} = socket
      ) do
    cond do
      form.source.valid? == false ->
        {:noreply,
         socket
         |> assign(:form, form)}

      true ->
        # dbg(prompt_params)

        {:noreply,
         socket
         |> assign_form()}
    end
  end
end
