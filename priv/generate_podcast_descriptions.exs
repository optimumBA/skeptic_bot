defmodule GeneratePodcastDescriptions do
  alias SkepticBot.Podcasts.DescriptionGeneratingWorker
  alias SkepticBot.Podcasts.Episode
  alias SkepticBot.Repo

  require Logger

  def start do
    Logger.info("Description generation is starting", ansi_color: :green)

    Episode
    |> Repo.all()
    |> Enum.each(&DescriptionGeneratingWorker.enqueue(%{"id" => &1.id}))

    Logger.info("Description generation is completed", ansi_color: :green)
  end
end

GeneratePodcastDescriptions.start()
