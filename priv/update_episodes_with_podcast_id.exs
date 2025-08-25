alias SkepticBot.Podcasts
alias SkepticBot.Podcasts.Episode
alias SkepticBot.Repo

require Logger

Logger.debug("Updating all episodes with the podcast_id of Tin Foil Hat",
  ansi_color: :green
)

podcast = Podcasts.get_podcast_by_name("Tin Foil Hat")

Repo.update_all(Episode, set: [podcast_id: podcast.id])

Logger.debug("Completed updating all episodes with the podcast_id of Tin Foil Hat",
  ansi_color: :green
)
