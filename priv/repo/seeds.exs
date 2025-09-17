# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     SkepticBot.Repo.insert!(%SkepticBot.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
alias SkepticBot.Podcasts

[
  %{name: "Tin Foil Hat"},
  %{name: "Look Into It"},
  %{name: "Candace"},
  %{name: "Deep Waters"}
]
|> Stream.reject(&Podcasts.get_podcast_by_name(&1.name))
|> Enum.each(&Podcasts.create_podcast/1)
