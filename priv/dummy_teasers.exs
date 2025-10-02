alias SkepticBot.Podcasts
alias SkepticBot.Podcasts.Episode
alias SkepticBot.Repo

require Logger

Logger.debug("Updating all episodes dummy teaser",
  ansi_color: :green
)

teaser =
  "Nelson Mandela, South Africa’s first Black president, symbolised freedom, resilience, and reconciliation leading the fight against."

Repo.update_all(Episode, set: [teaser: teaser])

Logger.debug("Completed updating all episodes dummy teaser",
  ansi_color: :green
)
