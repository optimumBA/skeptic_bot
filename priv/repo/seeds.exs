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

attrs = [%{name: "Tin Foil Hat"}, %{name: "Look Into It"}]
:ok = Enum.each(attrs, &Podcasts.create_podcast/1)
