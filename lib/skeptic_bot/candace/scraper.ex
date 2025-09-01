defmodule SkepticBot.Candace.Scraper do
  @moduledoc """
  Gets Candace Owens Episodes
  """

  alias SkepticBot.YtDlp.Scraper

  require Logger

  @candace_channel "https://www.youtube.com/@RealCandaceO/streams"

  @spec scrape :: :ok
  def scrape do
    cmd =
      "yt-dlp --cache-dir /tmp/yt-cache --date #{get_yesterday_date()} --cookies #{get_cookie_file()} --print \"%(title)s~~%(duration)s~~%(thumbnail)s~~%(webpage_url)s\" #{@candace_channel}"

    port = Port.open({:spawn, cmd}, [:binary, :stderr_to_stdout, :exit_status])
    Process.send_after(self(), {:close_port, port}, :timer.minutes(1))
    wait_for_episodes()
  end

  @spec scrape_from_file :: :ok
  def scrape_from_file do
    episodes =
      get_candace_episodes()

    Enum.each(episodes, &Scraper.process_candace_episode/1)
  end

  defp wait_for_episodes do
    receive do
      {_port, {:data, msg}} ->
        episode = process_message(msg)

        Scraper.process_candace_episode(episode)

        wait_for_episodes()

      {:close_port, port} ->
        Logger.info("Closed the port")
        Port.close(port)
        :ok
    end
  end

  defp get_candace_episodes do
    [:code.priv_dir(:skeptic_bot), "/dumps/candace_owens.txt"]
    |> Path.join()
    |> File.read!()
    |> format_channel_data()
  end

  defp process_message(msg) do
    msg
    |> String.trim("\n")
    |> String.split("~~")
    |> List.to_tuple()
  end

  defp format_channel_data(result) do
    result
    |> String.split("\n")
    |> Enum.map(fn x ->
      x
      |> String.split("~~")
      |> List.to_tuple()
    end)
    |> Enum.drop(-1)
  end

  defp get_cookie_file do
    Path.join([:code.priv_dir(:skeptic_bot), "/cookies/normal_cookies.txt"])
  end

  defp get_yesterday_date do
    {year, month, day} =
      Date.utc_today()
      |> Date.add(-1)
      |> Date.to_erl()

    "#{pad(year)}#{pad(month)}#{pad(day)}"
  end

  defp pad(value) when value < 10, do: "0#{value}"
  defp pad(value), do: "#{value}"
end
