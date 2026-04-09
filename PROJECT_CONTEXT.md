# SkepticBot - Project Context

## Project Overview

- **Purpose**: AI-powered podcast Q&A platform — scrapes conspiracy/alternative media podcasts, transcribes, embeds, and answers user questions via RAG.
- **Target Users**: Listeners of conspiracy/alternative media podcasts who want to search episode content via natural language.
- **Architecture**: Phoenix 1.8 LiveView, Oban pipeline (scrape -> download -> transcribe -> summarize -> embed), GenServer-based async prediction handling, pgvector for retrieval.
- **Key Integrations**: Replicate API (e5-large embeddings, Whisper transcription, GPT-4.1 LLM), Tigris S3 storage, yt-dlp, FFmpeg, FLAME isolated download pool, AppSignal.

## Domain Context Files

Detailed context is split by business domain. **Load the index (this file) always. Load domain files only when relevant to your task.**

| File                     | Domain                                                                  | Load when working on...                                                |
| ------------------------ | ----------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| `context/ingestion.md`   | Scrapers, download/transcode/transcribe pipeline, Tigris, FLAME, yt-dlp | New scraper, pipeline workers, storage, transcoding, download failures |
| `context/rag.md`         | Embeddings, pgvector retrieval, LLM generation, summary generation      | Retrieval thresholds, embedding model, LLM prompts, summarizer         |
| `context/questions.md`   | User question flow, Replicate webhooks, prediction handling, PubSub     | Question submission, webhook verification, prediction lifecycle        |
| `context/web.md`         | LiveView pages, components, routing, SEO, sitemap                       | HomeLive, QuestionLive, routes, meta tags, sitemap                     |
| `context/development.md` | Tech stack, CI, testing, env vars, pitfalls                             | CI failures, test setup, env config, debugging                         |

### Loading examples

- **New scraper**: `ingestion.md`
- **Tweak retrieval threshold**: `rag.md`
- **Webhook signature change**: `questions.md`
- **LiveView UI change**: `web.md` (+ `questions.md` if wiring PubSub updates)
- **Fixing CI or tests**: `development.md`
- **Cross-cutting (new pipeline step touching embeddings)**: `ingestion.md` + `rag.md`
