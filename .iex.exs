# maybe move some of this stuff to the scripts dir

alias SkepticBot.Podcasts.Episode
alias SkepticBot.Podcasts.TinfoilScraper
alias SkepticBot.Podcasts
alias SkepticBot.Repo

scrape_episodes = fn ->
  TinfoilScraper.scrape()
end

rag = fn question ->
  SkepticBot.Rag.generate(question)
end
