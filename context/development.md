# Development

## Tech Stack

- **Backend**: Elixir 1.18.3 / OTP 27.3.1, Phoenix 1.8.16, Bandit 1.14.1 HTTP server.
- **Frontend**: Phoenix LiveView `resume-built` fork (unchanged locked revision), Tailwind CSS, esbuild.
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
2. `mix ci` — `deps.unlock --check-unused`, `deps.audit`, `hex.audit`, `sobelow`, `format --check-formatted`, `npx prettier -c .`, `credo --strict`, `optimum.heex_check`, `dialyzer`, `test --cover --warnings-as-errors`.
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

## Main dependency maintenance (2026-10-31)

The main-branch CI repair updates audited dependencies, including Bandit, Plug,
PlugCrypto, Phoenix, Phoenix.HTML, HPAX, LazyHTML, Mint, Postgrex, Req and Swoosh.
Decimal 3 overrides the retained AppSignal fork's stale Decimal 2 constraint;
that fork has no Decimal API calls in `lib/`. Both AppSignal and LiveView Git
fork revisions remain unchanged. Req stays in the compatible 0.6 series.

The old Bandit/Plug handshake pins are replaced together. Verify a real HTTP
request, WebSocket upgrade and warm resumed LiveView join after changing this
pair; controller-render tests alone do not exercise the handshake. The two
identical guarded download-processing branches now share one implementation,
retaining every previously supported podcast name and existing error handling.

Prediction-handler tests run serially because they share a named GenServer.
After a completion broadcast, they synchronize with the handler before checking
jobs or releasing the SQL sandbox; the broadcast precedes sitemap insertion.
This replaces the fixed sleep and prevents background DB work outliving its test.

The baseline gate and its coverage settings remain intact. This repair does not
import experimental discovery/library/membership features or introduce KogenCredo.
Run the pinned full gate as described in the root README; its final rollback
removes test tables, so migrate the same isolated database before a subsequent
connectivity probe. Keep execution receipts and local probe tooling outside the
source checkout and iCloud.

## Credo adoption (2026-10-31)

[Code quality policy](../docs/code-quality.md) owns the released KogenCredo and
OptimumCredo integration, exact policy boundaries and regression coverage.
`make ci` retains the original gates and additionally scans standalone HEEx.
The source uses matchable missing-record errors in worker jobs; external adapter
error strings retain their existing contracts. Streaming DB operations and scraper
receives have finite deadlines. See the code-quality owner before changing checks
or declaring zero findings from a library's default no-op configuration.
