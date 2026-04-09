# RAG (Retrieval-Augmented Generation)

## Architecture

RAG orchestrates embedding generation, pgvector retrieval, and LLM answer generation. Used both for answering user questions and for generating episode summaries from transcriptions.

Query path: user query -> embed via Replicate e5-large -> pgvector L2 search over episodes + transcriptions -> assemble context -> Replicate GPT-4.1 generation -> PubSub broadcast to LiveView (see `context/questions.md`).

Summary path: new episode transcribed -> `SummaryGenerator` builds teaser (20 words) + summary (700 words) from full transcription via LLM.

## Core Modules

| Module                              | Purpose                                                                       |
| ----------------------------------- | ----------------------------------------------------------------------------- |
| `SkepticBot.Rag`                    | Top-level orchestration — `generate_embedding/1`, `predict_query/2`           |
| `SkepticBot.Rag.Retrieval`          | pgvector L2 search — top 6 episodes with best matching transcription segments |
| `SkepticBot.Rag.SummaryGenerator`   | Generates teaser + summary for new episodes                                   |
| `SkepticBot.Rag.Embedder`           | Behaviour — text embedding                                                    |
| `SkepticBot.Rag.ReplicateEmbedder`  | `beautyyuyanli/multilingual-e5-large`, 1024 dims                              |
| `SkepticBot.Rag.Generator`          | Behaviour — LLM generation                                                    |
| `SkepticBot.Rag.ReplicateGenerator` | `openai/gpt-4.1` via Replicate                                                |

## Oban Workers

| Worker                             | Queue                   | Notes                                               |
| ---------------------------------- | ----------------------- | --------------------------------------------------- |
| `Podcasts.SummaryGeneratingWorker` | `generating_summaries`  | Builds teaser + summary via LLM from transcription  |
| `Rag.EmbeddingsGeneratingWorker`   | `generating_embeddings` | Episode + transcription embeddings in batches of 32 |

## Vector Search

- **Dimensions**: 1024 (e5-large). All embeddings must match — mismatches fail pgvector ops.
- **Index**: pgvector IVFFlat, L2 distance, 100 lists.
- **Episode retrieval threshold**: 0.6 — top 6 episodes.
- **Related questions threshold**: 0.55–0.60.
- **Transcription segments**: each episode returned with its best-matching transcription chunks.

## RAG API

- `SkepticBot.Rag.generate_embedding(query)` -> `{embedding, episodes}`
- `SkepticBot.Rag.predict_query(context, query)` -> triggers async Replicate LLM prediction
- Retrieval works over `Podcasts.Episode` and `Podcasts.EpisodeTranscription` embedding columns.

## Integrations

- **Replicate Embeddings** — `beautyyuyanli/multilingual-e5-large`, 1024-dim output.
- **Replicate LLM** — `openai/gpt-4.1`, webhook-driven prediction flow.
- **pgvector** — PostgreSQL extension, IVFFlat index with 100 lists.

## Pitfalls

- **Strategy pattern required**: always call through behaviour modules (`Embedder`, `Generator`) — never `ReplicateEmbedder` directly. Enables Mox testing and implementation swaps.
- **Test embeddings**: use `List.duplicate(float, 1024)` for fixtures. `offset_embedding_fixture/2` creates embeddings with controlled L2 distance for retrieval threshold testing.
- **Batch size**: `EmbeddingsGeneratingWorker` processes 32 items per batch — tune carefully against Replicate rate limits.
