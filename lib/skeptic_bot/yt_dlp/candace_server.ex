defmodule SkepticBot.YtDlp.CandaceServer do
  @moduledoc """
  Uses ports to make request to fetch candace episodes
  """

  use GenServer

  alias SkepticBot.YtDlp.Scraper

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_state) do
    {:ok, %{}}
  end

  def read_cookie do
    File.read!(get_cookie_file())
  end

  @spec request_episodes :: :ok
  def request_episodes do
    cmd =
      "yt-dlp --no-cache-dir --dateafter 20240609 --cookies #{get_cookie_file()} --print \"%(title)s~~%(duration)s~~%(thumbnail)s~~%(webpage_url)s\" https://www.youtube.com/@RealCandaceO"

    GenServer.cast(__MODULE__, {:message, cmd})
  end

  @impl GenServer
  def handle_cast({:message, cmd}, state) do
    port = Port.open({:spawn, cmd}, [:binary, :stderr_to_stdout, :exit_status])

    state =
      state
      |> Map.put(:port, port)
      |> Map.put(:episodes, [])

    {:noreply, state}
  end

  @impl GenServer
  def handle_info({port, {:data, msg}}, state) do
    episode = process_message(msg)
    episodes = [episode | state.episodes]
    new_state = Map.put(state, :episodes, episodes)
    process_episodes(port, episodes, episode)
    {:noreply, new_state}
  end

  @impl GenServer
  def handle_info({port, {:exit_status, _status}}, state) do
    Port.close(port)
    {:noreply, Map.delete(state, :port)}
  end

  defp get_cookie_file do
    Path.join([:code.priv_dir(:skeptic_bot), "/cookies/normal_cookies.txt"])
  end

  defp process_episodes(port, episodes, {_title, _duration, _thumbnail, webpage_url})
       when webpage_url == "https://www.youtube.com/watch?v=qQBuDkrGglM" do
    Port.close(port)

    episodes
    |> Enum.take(-4)
    |> Scraper.process_candace_episodes()
  end

  defp process_episodes(_port, _episodes, _episode_details), do: :ok

  defp process_message(msg) do
    msg
    |> String.trim("\n")
    |> String.split("~~")
    |> List.to_tuple()
  end
end
