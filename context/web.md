# Web Layer (LiveView, Routing, SEO)

## Architecture

Phoenix LiveView handles the public-facing UI. Two main pages: the landing page with a question form and latest episodes carousel, and a question detail page that streams AI answers via PubSub as they arrive.

No authentication — the application is fully public.

## LiveViews & Controllers

| Module                            | Purpose                                                                             |
| --------------------------------- | ----------------------------------------------------------------------------------- |
| `SkepticBotWeb.HomeLive.Index`    | Landing page — question form, latest episodes carousel, async RAG pipeline kickoff  |
| `SkepticBotWeb.QuestionLive.Show` | Results page — AI answer, related episodes carousel, related questions, PubSub live |
| `SkepticBotWeb.WebhookController` | Replicate webhook receiver (see `context/questions.md`)                             |
| `SkepticBotWeb.HealthController`  | `GET /health`                                                                       |

## Components

| Module                                | Purpose                                                                    |
| ------------------------------------- | -------------------------------------------------------------------------- |
| `SkepticBotWeb.PodcastComponents`     | Episode card carousel, related question cards, duration, per-platform URLs |
| `SkepticBotWeb.SeoMetaTagsComponents` | OpenGraph, Twitter Card, and standard meta tags                            |

## Routing

- **Public**: `GET /` (HomeLive.Index), `GET /questions/:id` (QuestionLive.Show), `GET /health`.
- **Webhook**: `POST /webhook/replicate` — `:webhook` pipeline, HMAC verified.
- **Dev**: `/dev/dashboard` (LiveDashboard), `/dev/mailbox` (Swoosh preview).
- **Pipelines**: `:browser` (session, CSRF), `:api` (JSON), `:webhook` (`VerifyReplicateWebhook`).

## SEO & Sitemap

- `SkepticBot.Sitemap` — XML sitemap generation. Home priority 1.0, questions 0.8.
- `Workers.SitemapGeneratorWorker` — Oban worker on queue `seo_sitemap`, regenerates the sitemap.
- `SeoMetaTagsComponents` — injects OpenGraph / Twitter Card / standard tags on every page.

## Frontend Stack

- Phoenix LiveView 1.1.27.
- Tailwind CSS.
- esbuild for JS bundling.
- Prettier for JS formatting (checked in CI).

## Patterns

- **PubSub-driven UI**: `QuestionLive.Show` subscribes to `QuestionsBroadcast` on mount; webhook-driven prediction updates flow through to the page without polling.
- **Flash-based error handling**: LiveView flash messages surface errors from context calls.
- **Context-free view layer**: LiveViews call into `Podcasts`, `Prompts`, and `Rag` — never into schemas or repo directly.
