# SkepticBot - Project Context

## Project Overview

### Mission & Goals

- **Primary Purpose**: AI-powered podcast Q&A platform that scrapes conspiracy/alternative media podcasts, transcribes them, generates vector embeddings, and answers user questions using RAG (Retrieval-Augmented Generation)
- **Target Users**: Listeners of conspiracy/alternative media podcasts who want to search and explore episode content via natural language questions
- **Key Value Propositions**: Semantic search across podcast transcriptions, AI-generated answers with source episode references, automatic episode scraping/transcription/summarization pipeline

### Architecture Overview

- **Architecture Pattern**: Phoenix LiveView with Oban background job pipeline, GenServer-based async prediction handling, and pgvector-powered RAG
- **Data Flow**:
  1. **Ingestion**: Scrapers → DownloadingWorker (FLAME pool) → TranscribingWorker → SummaryGeneratingWorker → EmbeddingsGeneratingWorker
  2. **Q&A**: User query → Embedding → pgvector retrieval → LLM generation → PubSub broadcast → LiveView update
- **Key Integrations**: Replicate API (embeddings via e5-large, transcription via Whisper, LLM via GPT-4.1), Tigris S3 storage, yt-dlp, FFmpeg, PostgreSQL with pgvector

## Module Directory

### Core Modules

- **SkepticBot.Podcasts**: Context for podcast and episode CRUD, transcription management, streaming queries
- **SkepticBot.Prompts**: Context for user questions, vector similarity search (related episodes, related questions), episode detail retrieval
- **SkepticBot.Rag**: RAG orchestration — embedding generation, vector retrieval, LLM response generation with skeptical analysis persona
- **SkepticBot.Rag.Retrieval**: pgvector L2 distance search — finds top 6 episodes (threshold 0.6) with best matching transcription segments
- **SkepticBot.Rag.SummaryGenerator**: Generates teaser (20 words) + summary (700 words) for new episodes using full transcription

### Schemas

- **SkepticBot.Podcasts.Podcast**: Podcast metadata (name). Parent of episodes
- **SkepticBot.Podcasts.Episode**: Episode with title, summary, teaser, thumbnail, episode_length, external_id, 1024-dim embedding vector. Belongs to Podcast
- **SkepticBot.Podcasts.EpisodeTranscription**: Timestamped transcript chunks with 1024-dim embedding. Compound unique on (episode_id, timestamp)
- **SkepticBot.Prompts.UserQuestion**: User query with title, description, embedding, and embedded list of PodcastEpisode references
- **SkepticBot.Prompts.PodcastEpisode**: Embedded schema (episode_id + timestamp) within UserQuestion

### Webhook & Prediction Handling

- **SkepticBot.WebhookHandler**: GenServer routing Replicate webhook callbacks to waiting processes via PredictionRegistry
- **SkepticBot.PredictionHandler**: GenServer linking user questions to LLM predictions, broadcasts results via PubSub
- **SkepticBot.ReplicateClient**: Shared Replicate API interaction — starts predictions, registers for webhooks, handles timeouts (5 min default)

### Background Workers (Oban)

- **Podcasts.ScrapingWorker**: Hourly cron scraping all podcast sources (queue: `:scraping`)
- **Podcasts.DownloadingWorker**: Downloads/transcodes episodes via FLAME pool (queue: `:downloading`, max_attempts: 5)
- **Podcasts.TranscribingWorker**: Transcribes audio via Replicate Whisper, cleans up audio from storage (queue: `:transcribing`)
- **Podcasts.SummaryGeneratingWorker**: Generates teaser + summary via LLM (queue: `:generating_summaries`)
- **Rag.EmbeddingsGeneratingWorker**: Generates episode + transcription embeddings in batches of 32 (queue: `:generating_embeddings`)
- **Workers.SitemapGeneratorWorker**: Updates XML sitemap (queue: `:seo_sitemap`)

### Scrapers

- **Podcasts.TinfoilScraper**: Scrapes Sam Tripoli's network (vid.samtripoli.com API) — Tin Foil Hat, Zero, Doom Scrollin, Cash Daddies, Union of the Unwanted
- **BrokenSimulation.Scraper**: YouTube @SamTripoli/videos (filters "Broken Sim" prefix)
- **Candace.Scraper**: YouTube @RealCandaceO/streams
- **DeepWaters.Scraper**: YouTube @deepwaterscsc/videos
- **NephilimDeathSquad.Scraper**: YouTube @NephilimDeathSquad/streams
- **LookIntoIt.Scraper**: Eddie Bravo content from Rumble + Rokfin

### Infrastructure Modules

- **SkepticBot.Storage.StorageProvider**: Abstract storage interface (behaviour)
- **SkepticBot.Storage.TigrisStorageProvider**: S3-compatible Tigris cloud storage with AWS SigV4 auth
- **SkepticBot.Podcasts.Downloader / ReqDownloader / YtDlpDownloader**: Strategy pattern for HTTP vs yt-dlp downloads
- **SkepticBot.Podcasts.Transcoder / FfmpegTranscoder**: Video-to-audio transcoding via FFmpeg
- **SkepticBot.Podcasts.Transcriber / ReplicateTranscriber**: Speech-to-text via Replicate Whisper (vaibhavs10/incredibly-fast-whisper)
- **SkepticBot.Rag.Embedder / ReplicateEmbedder**: Text embedding via Replicate (beautyyuyanli/multilingual-e5-large, 1024 dims)
- **SkepticBot.Rag.Generator / ReplicateGenerator**: LLM generation via Replicate (openai/gpt-4.1)
- **SkepticBot.YtDlp.ChannelClient / YtDlpChannelClient**: yt-dlp command execution for YouTube channel scraping
- **SkepticBot.YtDlp.EpisodeProcessor**: Processes scraped videos into DB episodes, extracts external IDs from platform URLs
- **EctoInterval**: Custom Ecto type for PostgreSQL interval (months, days, seconds)

### Web Modules

- **SkepticBotWeb.HomeLive.Index**: Main landing page — question form, latest episodes carousel, async RAG pipeline
- **SkepticBotWeb.QuestionLive.Show**: Results page — AI answer, related episodes carousel, related questions, real-time PubSub updates
- **SkepticBotWeb.PodcastComponents**: Episode card carousel, related question cards, duration formatting, platform-specific episode URLs
- **SkepticBotWeb.SeoMetaTagsComponents**: OpenGraph, Twitter Card, and standard meta tags
- **SkepticBotWeb.WebhookController**: Replicate webhook receiver with signature verification
- **SkepticBotWeb.Plugs.VerifyReplicateWebhook**: HMAC-SHA256 webhook signature validation
- **SkepticBotWeb.Plugs.BodyReader**: Raw body capture for webhook verification
- **SkepticBot.Sitemap**: XML sitemap generation (home priority 1.0, questions 0.8)

## Tech Stack & Patterns

### Primary Technologies

- **Backend**: Elixir 1.18.3 / OTP 27.3.1, Phoenix 1.8.1, Bandit HTTP server
- **Frontend**: Phoenix LiveView 1.1.27, Tailwind CSS, esbuild
- **Database**: PostgreSQL with pgvector extension (1024-dim vectors, IVFFlat index with 100 lists)
- **Testing**: ExUnit with Mox (8 mock modules), custom fixtures (not ExMachina factories despite dep), Oban.Testing
- **Background Jobs**: Oban 2.19.4 with basic engine
- **Monitoring**: AppSignal (forked version with scoped working directory)
- **Distributed Compute**: FLAME pool for isolated download operations (min: 0, max: 1, timeout: 10 min)

### Coding Conventions

- **File Organization**: Standard Phoenix context pattern — `lib/skeptic_bot/` for business logic, `lib/skeptic_bot_web/` for web layer
- **Naming Patterns**: Contexts as plural nouns (Podcasts, Prompts), workers suffixed with `Worker`, scrapers under podcast-named directories
- **Code Style**: `mix format` + Prettier for JS, Credo strict mode, Dialyzer, Sobelow security checks

### Common Patterns

- **Strategy Pattern**: All external services use behaviour modules with configurable implementations (Embedder, Generator, Downloader, Transcoder, Transcriber, StorageProvider, HttpClient, ChannelClient). Configured via `Application.get_env` with test mocks via Mox
- **Oban Pipeline**: Scrapers → DownloadingWorker → TranscribingWorker → SummaryGeneratingWorker → EmbeddingsGeneratingWorker (each enqueues the next)
- **GenServer Prediction Flow**: ReplicateClient starts prediction → WebhookHandler registers for callback → Replicate sends webhook → WebhookHandler dispatches → PredictionHandler updates question → PubSub broadcasts to LiveView
- **Vector Search**: pgvector L2 distance with configurable thresholds (episodes: 0.6, related questions: 0.55-0.60)
- **FLAME Isolation**: Heavy download operations run in isolated FLAME pool to prevent memory/resource issues on main node

## API Contracts & Interfaces

### Internal APIs

- **Podcasts Context**: `create_episode/1`, `get_episode/1`, `update_episode/2`, `get_episode_by_external_id/1`, `get_latest_episodes/1`, `episode_exists?/1`
- **Prompts Context**: `create_question/1`, `get_question/1`, `update_question/2`, `get_related_episodes/3`, `get_other_episodes/2`, `get_related_questions/2`
- **Rag**: `generate_embedding(query)` → `{embedding, episodes}`, `predict_query(context, query)` → prediction via Replicate
- **PredictionHandler**: `make_llm_request(context, question)` → triggers async LLM generation
- **QuestionsBroadcast**: `subscribe(topic)`, `broadcast_title_and_description(topic, message)` — PubSub for real-time question updates

### External APIs

- **Replicate API**: Predictions for embeddings (e5-large), transcription (Whisper), and LLM generation (GPT-4.1). Webhook-based async results
- **Tigris Storage**: S3-compatible API for audio files and thumbnails (upload/delete with public ACL)
- **vid.samtripoli.com**: REST API for Sam Tripoli podcast network episode metadata
- **yt-dlp**: CLI tool for YouTube/Rumble/Rokfin video metadata and audio extraction

### Routing Architecture

- **Public Routes**: `GET /` (HomeLive.Index), `GET /questions/:id` (QuestionLive.Show), `GET /health` (HealthController)
- **Webhook Routes**: `POST /webhook/replicate` (WebhookController) — protected by HMAC signature verification
- **Dev Routes**: `/dev/dashboard` (LiveDashboard), `/dev/mailbox` (Swoosh preview)
- **Pipelines**: `:browser` (session, CSRF), `:api` (JSON), `:webhook` (VerifyReplicateWebhook plug)

## Development Guidelines

### Feature Development

- **Context Boundaries**: Podcasts context owns episodes/transcriptions/scraping. Prompts context owns questions and vector search. Rag module orchestrates AI operations across both
- **Testing Strategy**: Custom fixture modules in `test/support/fixtures/` (not ExMachina despite dependency). Mox for all external services (8 mock modules). Oban.Testing for job assertions. `async: true` for DataCase tests, `async: false` for Oban worker tests
- **Database Changes**: UUID primary keys (`binary_id`), pgvector for embeddings (1024 dims), EctoInterval for timestamps, JSON columns for flexible structures

### Integration Points

- **Authentication**: None — public-facing application
- **Error Handling**: Flash messages in LiveView, `{:ok, _} | {:error, _}` tuples throughout contexts, Oban retry for failed workers
- **Logging**: AppSignal integration with logging backend in production

### Environment Configuration

**Required (Production)**:

- `DATABASE_URL`, `SECRET_KEY_BASE`, `PHX_HOST`, `PHX_SERVER`
- `REPLICATE_API_TOKEN`, `REPLICATE_WEBHOOK_SECRET`
- `TIGRIS_BUCKET`, `TIGRIS_ACCESS_KEY_ID`, `TIGRIS_SECRET_ACCESS_KEY`
- `YOUTUBE_COOKIE_FILE` (base64-encoded)
- `APPSIGNAL_APP_ENV`, `APPSIGNAL_PUSH_API_KEY`

**Optional**:

- `SCRAPE` — enables Oban cron queues for podcast scraping
- `PORT` (default: 4000), `POOL_SIZE` (default: 10), `DNS_CLUSTER_QUERY`, `ECTO_IPV6`

### CI Pipeline

Run via `make ci` which executes:

1. `MIX_ENV=test mix compile` — pre-warm
2. `mix ci` — deps.unlock --check-unused, deps.audit, hex.audit, sobelow, format --check-formatted, npx prettier -c ., credo --strict, dialyzer, test --cover --warnings-as-errors
3. `MIX_ENV=test mix ecto.rollback --all --quiet` — DB cleanup

### Development Server

- `make server` — starts Phoenix with ngrok tunnel (needed for Replicate webhooks)
- `make iex_server` — interactive server with ngrok
- Dev database: `skeptic_bot_dev` on localhost:5432

## Common Pitfalls & Solutions

### Known Issues

- **Webhook verification requires raw body**: The BodyReader plug captures raw request body before parsing, which is needed for HMAC signature verification. Custom body reader is set on the endpoint
- **FLAME pool concurrency**: Download pool is limited to max 1 runner with concurrency 2 — heavy scraping can bottleneck here
- **yt-dlp cookie authentication**: YouTube requires cookie file for age-restricted content. Cookie file is base64-encoded in `YOUTUBE_COOKIE_FILE` env var and decoded at runtime
- **Vector embedding dimensions**: All embeddings must be 1024 dimensions (e5-large model). Mismatched dimensions will fail pgvector operations
- **Oban scraping queues only enabled with SCRAPE env var**: If `SCRAPE` is not set, no cron scraping jobs run

### Best Practices

- **Strategy pattern for external services**: Always use the behaviour module (e.g., `Embedder`, not `ReplicateEmbedder` directly). This enables Mox testing and future implementation swaps
- **Worker chaining**: Each Oban worker enqueues the next step in the pipeline. Don't skip steps — the chain is: Download → Transcribe → Summarize → Embed
- **Embedding test fixtures**: Use `List.duplicate(float, 1024)` for test embeddings. The `offset_embedding_fixture/2` helper creates embeddings with controlled L2 distance for testing retrieval thresholds
