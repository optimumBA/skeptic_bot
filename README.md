# Skeptic.bot

Skeptic.bot is a Phoenix application for searching conspiracy and alternative
podcasts, discovering related discussions, and reading AI-assisted answers
linked back to the source material.

> [!NOTE]
> **Open source, closed contribution.** The source code is available under the
> Apache License 2.0. This repository does not accept issues or pull requests and
> is not a public support channel. You are welcome to study the code, fork it and
> adapt it under the license.

## What is included

- Podcast and episode discovery.
- Episode ingestion and transcription workflows.
- Retrieval and AI-assisted question answering.
- A Phoenix web application for search and saved answers.

## Local setup

### Requirements

- FFmpeg (`brew install ffmpeg` on macOS).
- Elixir, Erlang and Node versions from [`.tool-versions`](.tool-versions),
  installed with [mise](https://mise.jdx.dev) or equivalent tools.
- PostgreSQL.

### Start the application

1. Install the required runtimes with `mise install`.
2. Start PostgreSQL.
3. Copy [`.env.sample`](.env.sample) to `.env` and provide the integrations you
   intend to use.
4. Run `mix setup`.
5. Start Phoenix with `make server`.
6. Open [localhost:4000](http://localhost:4000).

Tidewave users can follow the current
[MCP proxy setup](https://elixirdrops.net/d/UAo4BtYi).

## Usage

Start the server with IEx:

```bash
make iex_server
```

Scrape episodes:

```elixir
SkepticBot.Podcasts.TinfoilScraper.scrape()
```

Ask a question:

```elixir
SkepticBot.Rag.generate("Who killed Tupac?")
```

## Checks

Run the complete project gate before committing:

```sh
make ci
```

For a coverage report, run `mix coveralls` or `mix coveralls.html`. Generate the
Elixir documentation with `mix docs --formatter html --open`.

## License and product identity

The source code is licensed under the [Apache License 2.0](LICENSE). The license
does not grant permission to operate a modified service as Skeptic.bot.

Forks and public deployments must use their own name, logo, visual identity,
domain, content, credentials and data. The Skeptic.bot name, logo and associated
brand assets are not licensed under Apache-2.0. You may refer to Skeptic.bot only
as reasonably necessary to describe the origin of the software. See
[Product identity](BRANDING.md) for the exact boundary.

## Project map

- `lib/` contains the application and web code.
- `assets/` contains browser code and styles.
- `priv/` contains migrations, repository data and static files.
- `test/` contains automated checks and support code.
- `config/` contains compile-time and runtime configuration.
