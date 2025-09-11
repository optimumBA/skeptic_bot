# maybe move some of this stuff to the scripts dir

alias SkepticBot.Podcasts.Episode
alias SkepticBot.Podcasts.TinfoilScraper
alias SkepticBot.Podcasts
alias SkepticBot.Repo

scrape_episodes = fn ->
  TinfoilScraper.scrape()
end

scrape_an_episode = fn external_id ->
  TinfoilScraper.scrape_episode(external_id)
end

rag = fn question ->
  SkepticBot.Rag.generate(question)
end

get_l2_distance = fn embedding_value_1, embedding_value_2 ->
  embedding_1 = List.duplicate(embedding_value_1, 1024)
  embedding_2 = List.duplicate(embedding_value_2, 1024)

  embedding_1
  |> Enum.zip_with(embedding_2, fn x, y -> :math.pow(x - y, 2) end)
  |> Enum.sum()
  |> :math.sqrt()
end
