defmodule GeneratePodcastTeasersAndSummaries do
  alias SkepticBot.Podcasts.SummaryGeneratingWorker
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Repo

  require Logger

  def start do
    Logger.info("Description generation is starting", ansi_color: :green)

    transformation = fn ->
      Episode
      |> Repo.stream(max_rows: 100)
      |> Stream.each(
        &SummaryGeneratingWorker.enqueue(%{"id" => &1.id, "episode_status" => "existing"})
      )
      |> Stream.run()
    end

    Repo.transaction(transformation, timeout: :infinity)

    Logger.info("Description generation is completed", ansi_color: :green)
  end
end

{:ok, _apps} = Application.ensure_all_started(:skeptic_bot)

GeneratePodcastTeasersAndSummaries.start()
