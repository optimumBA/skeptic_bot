# SkepticBot

To start your Phoenix server:

  * Install ffmpeg: `brew install ffmpeg`
  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Usage

Start the server with IEx:
```bash
iex -S mix phx.server
```

Scrape episodes:
```elixir
SkepticBot.Podcasts.TinfoilScraper.scrape()
```

Ask a question:
```elixir
SkepticBot.Rag.generate("Who killed Tupac?")
```
