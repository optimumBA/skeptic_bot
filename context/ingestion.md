# Ingestion Pipeline

## Architecture

Podcast episodes flow through a chained Oban pipeline. Each worker enqueues the next step, keeping stages isolated and independently retryable.

Pipeline: `ScrapingWorker` -> `DownloadingWorker` -> `TranscribingWorker` -> `SummaryGeneratingWorker` -> `EmbeddingsGeneratingWorker`.

Scrapers discover new episodes hourly. Downloads run inside a FLAME pool to isolate heavy yt-dlp and FFmpeg work from the main node. Transcription and summarization are async Replicate calls; embeddings are batched.

## Schemas

- `SkepticBot.Podcasts.Podcast` — podcast metadata (name). Parent of episodes.
- `SkepticBot.Podcasts.Episode` — title, summary, teaser, thumbnail, `episode_length` (EctoInterval), `external_id`, 1024-dim embedding. Belongs to Podcast.
- `SkepticBot.Podcasts.EpisodeTranscription` — timestamped transcript chunks with 1024-dim embedding. Compound unique on `(episode_id, timestamp)`.

## Context Modules

| Module                                     | Purpose                                                         |
| ------------------------------------------ | --------------------------------------------------------------- |
| `SkepticBot.Podcasts`                      | Episode CRUD, transcription management, streaming queries       |
| `SkepticBot.Podcasts.Downloader`           | Behaviour — download strategy dispatch                          |
| `SkepticBot.Podcasts.ReqDownloader`        | HTTP download via Req                                           |
| `SkepticBot.Podcasts.YtDlpDownloader`      | yt-dlp download for YouTube/Rumble/Rokfin                       |
| `SkepticBot.Podcasts.Transcoder`           | Behaviour — video-to-audio transcoding                          |
| `SkepticBot.Podcasts.FfmpegTranscoder`     | FFmpeg implementation                                           |
| `SkepticBot.Podcasts.Transcriber`          | Behaviour — speech-to-text                                      |
| `SkepticBot.Podcasts.ReplicateTranscriber` | `vaibhavs10/incredibly-fast-whisper` on Replicate               |
| `SkepticBot.YtDlp.ChannelClient`           | Behaviour — YouTube channel listing                             |
| `SkepticBot.YtDlp.YtDlpChannelClient`      | yt-dlp CLI implementation                                       |
| `SkepticBot.YtDlp.EpisodeProcessor`        | Converts scraped videos into DB episodes, extracts external IDs |
| `SkepticBot.Storage.StorageProvider`       | Behaviour — blob storage interface                              |
| `SkepticBot.Storage.TigrisStorageProvider` | S3-compatible Tigris storage with AWS SigV4 auth                |

## Oban Workers

| Worker                             | Queue                   | Notes                                              |
| ---------------------------------- | ----------------------- | -------------------------------------------------- |
| `Podcasts.ScrapingWorker`          | `scraping`              | Hourly cron — scrapes all sources                  |
| `Podcasts.DownloadingWorker`       | `downloading`           | FLAME pool, `max_attempts: 5`                      |
| `Podcasts.TranscribingWorker`      | `transcribing`          | Replicate Whisper; cleans audio from storage after |
| `Podcasts.SummaryGeneratingWorker` | `generating_summaries`  | See `context/rag.md`                               |
| `Rag.EmbeddingsGeneratingWorker`   | `generating_embeddings` | See `context/rag.md`                               |

## Scrapers

| Module                       | Source                                                                                            |
| ---------------------------- | ------------------------------------------------------------------------------------------------- |
| `Podcasts.TinfoilScraper`    | `vid.samtripoli.com` API — Tin Foil Hat, Zero, Doom Scrollin, Cash Daddies, Union of the Unwanted |
| `BrokenSimulation.Scraper`   | YouTube `@SamTripoli/videos` (filters "Broken Sim" prefix)                                        |
| `Candace.Scraper`            | YouTube `@RealCandaceO/streams`                                                                   |
| `DeepWaters.Scraper`         | YouTube `@deepwaterscsc/videos`                                                                   |
| `NephilimDeathSquad.Scraper` | YouTube `@NephilimDeathSquad/streams`                                                             |
| `LookIntoIt.Scraper`         | Eddie Bravo content from Rumble + Rokfin                                                          |

## Podcasts Context API

- `create_episode/1`, `get_episode/1`, `update_episode/2`
- `get_episode_by_external_id/1`, `episode_exists?/1`
- `get_latest_episodes/1`

## Integrations

- **yt-dlp** — CLI for YouTube/Rumble/Rokfin metadata and audio extraction. Requires cookie file for age-restricted content.
- **FFmpeg** — video-to-audio transcode before transcription upload.
- **Tigris** — S3-compatible storage for audio files and thumbnails (public ACL).
- **Replicate Whisper** — `vaibhavs10/incredibly-fast-whisper`, webhook-driven.
- **FLAME** — isolated pool for downloads, `min: 0`, `max: 1`, `timeout: 10 min`.

## Pitfalls

- **FLAME pool concurrency**: download pool is capped at max 1 runner with concurrency 2 — heavy scraping bottlenecks here.
- **yt-dlp cookies**: YouTube requires `YOUTUBE_COOKIE_FILE` (base64-encoded) for age-restricted content; decoded at runtime.
- **Worker chain order**: never skip steps. Download -> Transcribe -> Summarize -> Embed.
- **Cron gated by `SCRAPE`**: without the `SCRAPE` env var, no scraping cron jobs run.
- **Audio cleanup**: `TranscribingWorker` deletes audio from Tigris after transcription to control storage costs.
