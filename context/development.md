# Development

## Tech Stack

- **Backend**: Elixir 1.18.3 / OTP 27.3.1, Phoenix 1.8.1, Bandit HTTP server.
- **Frontend**: Phoenix LiveView 1.1.27, Tailwind CSS, esbuild.
- **Database**: PostgreSQL with pgvector extension (1024-dim vectors, IVFFlat index, 100 lists).
- **Background Jobs**: Oban 2.19.4 with basic engine.
- **Testing**: ExUnit with Mox (8 mock modules), custom fixtures, Oban.Testing.
- **Monitoring**: AppSignal (forked version with scoped working directory).
- **Distributed Compute**: FLAME pool for isolated downloads (`min: 0`, `max: 1`, `timeout: 10 min`).

## File Organization

- Standard Phoenix context pattern — `lib/skeptic_bot/` for business logic, `lib/skeptic_bot_web/` for web layer.
- Contexts as plural nouns (`Podcasts`, `Prompts`). Workers suffixed `Worker`. Scrapers under podcast-named directories.
- Code style: `mix format` + Prettier for JS, Credo strict, Dialyzer, Sobelow.
- UUID primary keys (`binary_id`). `EctoInterval` custom type for PostgreSQL `interval`.

## Context Boundaries

- `Podcasts` owns episodes, transcriptions, scraping.
- `Prompts` owns user questions and vector search over questions/episodes.
- `Rag` orchestrates AI operations across both — embedding, retrieval, generation.
- No authentication — the app is fully public.
- Errors flow as `{:ok, _} | {:error, _}` tuples from contexts; LiveView surfaces them as flash.

## Testing Strategy

- Custom fixture modules under `test/support/fixtures/` (not ExMachina, despite the dependency being present).
- Mox for all external services (Embedder, Generator, Downloader, Transcoder, Transcriber, StorageProvider, HttpClient, ChannelClient).
- `Oban.Testing` for job assertions.
- `async: true` for DataCase tests; `async: false` for Oban worker tests.
- Embedding fixtures: `List.duplicate(float, 1024)`. Use `offset_embedding_fixture/2` for controlled L2 distance.

## CI Pipeline

Run via `make ci`:

1. `MIX_ENV=test mix compile` — pre-warm.
2. `mix ci` — `deps.unlock --check-unused`, `deps.audit`, `hex.audit`, `sobelow`, `format --check-formatted`, `npx prettier -c .`, `credo --strict`, `dialyzer`, `test --cover --warnings-as-errors`.
3. `MIX_ENV=test mix ecto.rollback --all --quiet` — DB cleanup.

## Development Server

- `make server` — Phoenix with ngrok tunnel (needed for Replicate webhooks).
- `make iex_server` — interactive server with ngrok.
- Dev database: `skeptic_bot_dev` on `localhost:5432`.

## Environment Variables

**Required (production)**:

| Variable                   | Purpose                                   |
| -------------------------- | ----------------------------------------- |
| `DATABASE_URL`             | Postgres connection string                |
| `SECRET_KEY_BASE`          | Phoenix secret                            |
| `PHX_HOST`                 | Public hostname                           |
| `PHX_SERVER`               | Enables server startup                    |
| `REPLICATE_API_TOKEN`      | Replicate API auth                        |
| `REPLICATE_WEBHOOK_SECRET` | HMAC signing key for webhook verification |
| `TIGRIS_BUCKET`            | Tigris bucket name                        |
| `TIGRIS_ACCESS_KEY_ID`     | Tigris S3 access key                      |
| `TIGRIS_SECRET_ACCESS_KEY` | Tigris S3 secret                          |
| `YOUTUBE_COOKIE_FILE`      | base64-encoded yt-dlp cookie file         |
| `APPSIGNAL_APP_ENV`        | AppSignal environment                     |
| `APPSIGNAL_PUSH_API_KEY`   | AppSignal key                             |

**Optional**:

| Variable            | Purpose                           |
| ------------------- | --------------------------------- |
| `SCRAPE`            | Enables Oban cron scraping queues |
| `PORT`              | HTTP port (default 4000)          |
| `POOL_SIZE`         | Ecto pool size (default 10)       |
| `DNS_CLUSTER_QUERY` | libcluster DNS query              |
| `ECTO_IPV6`         | IPv6 connection flag              |

## Common Pitfalls

- **Raw body for webhook verification**: `BodyReader` plug must be configured on the endpoint before any JSON parser — otherwise HMAC verification fails.
- **FLAME pool bottleneck**: downloads are capped at 1 runner; heavy scraping backs up here.
- **yt-dlp cookie file**: YouTube age-restricted content requires `YOUTUBE_COOKIE_FILE`, base64-encoded.
- **Embedding dimensions**: all embeddings must be 1024 (e5-large). Mismatches fail pgvector ops.
- **Scraping gated by `SCRAPE`**: cron queues only run when `SCRAPE` is set.
- **Strategy pattern everywhere**: call through the behaviour module, not the concrete implementation — required for Mox tests.
- **Worker chain**: Download -> Transcribe -> Summarize -> Embed. Never skip steps.
