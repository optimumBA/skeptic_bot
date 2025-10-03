alias SkepticBot.Podcasts
alias SkepticBot.Podcasts.Episode
alias SkepticBot.Repo

require Logger

Logger.debug("Updating all episodes dummy teaser",
  ansi_color: :green
)

teaser =
  "What if ancient giants once stalked the earth with bizarre features? Prepare for secrets, symbols, and a wild historical ride."

Repo.update_all(Episode, set: [teaser: teaser])

Logger.debug("Completed updating all episodes dummy teaser",
  ansi_color: :green
)
