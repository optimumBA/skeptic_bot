# User Questions & Prediction Flow

## Architecture

Users submit natural-language questions. The system embeds the query, retrieves related episodes, kicks off an async LLM prediction via Replicate, and streams results back to the LiveView through PubSub once the webhook fires.

Flow: user submits -> `Prompts.create_question/1` -> `Rag.generate_embedding` -> related episodes attached -> `PredictionHandler.make_llm_request/2` -> `ReplicateClient` starts prediction -> `WebhookHandler` registers callback -> Replicate POSTs to `/webhook/replicate` -> `WebhookController` dispatches to `WebhookHandler` -> `PredictionHandler` updates `UserQuestion` -> `QuestionsBroadcast` publishes -> LiveView re-renders.

## Schemas

- `SkepticBot.Prompts.UserQuestion` — title, description, 1024-dim embedding, embedded list of `PodcastEpisode` references.
- `SkepticBot.Prompts.PodcastEpisode` — embedded schema `(episode_id, timestamp)` within a `UserQuestion`.

## Core Modules

| Module                          | Purpose                                                                                              |
| ------------------------------- | ---------------------------------------------------------------------------------------------------- |
| `SkepticBot.Prompts`            | User question CRUD, vector similarity search (related episodes, related questions), episode lookup   |
| `SkepticBot.PredictionHandler`  | GenServer — links user questions to LLM predictions, broadcasts results via PubSub                   |
| `SkepticBot.WebhookHandler`     | GenServer — routes Replicate webhook callbacks to waiting processes via PredictionRegistry           |
| `SkepticBot.ReplicateClient`    | Shared Replicate API interaction — starts predictions, registers for webhooks, 5 min default timeout |
| `SkepticBot.QuestionsBroadcast` | PubSub — subscribe/broadcast for real-time question updates                                          |

## Webhook Handling

- **Route**: `POST /webhook/replicate` -> `SkepticBotWeb.WebhookController`.
- **Pipeline**: `:webhook` — runs `VerifyReplicateWebhook` plug.
- **`SkepticBotWeb.Plugs.VerifyReplicateWebhook`** — HMAC-SHA256 signature validation against `REPLICATE_WEBHOOK_SECRET`.
- **`SkepticBotWeb.Plugs.BodyReader`** — captures raw request body before parsing (required for HMAC verification). Set as custom body reader on the endpoint.

## Prompts Context API

- `create_question/1`, `get_question/1`, `update_question/2`
- `get_related_episodes/3`, `get_other_episodes/2`, `get_related_questions/2`

## Prediction API

- `PredictionHandler.make_llm_request(context, question)` — triggers async LLM generation.
- `QuestionsBroadcast.subscribe(topic)`, `QuestionsBroadcast.broadcast_title_and_description(topic, message)`.

## Integrations

- **Replicate API** — webhook-based async predictions, HMAC-signed.
- **Phoenix PubSub** — real-time updates from webhook handler to LiveView.

## Pitfalls

- **Raw body for webhook verification**: `BodyReader` must be registered on the endpoint — without it, Plug parses the body and HMAC verification fails.
- **Prediction timeouts**: `ReplicateClient` has a 5-minute default timeout. Long LLM calls past that are dropped.
- **PredictionRegistry lifecycle**: predictions must be registered with `WebhookHandler` before Replicate can possibly respond — register before starting the prediction.
