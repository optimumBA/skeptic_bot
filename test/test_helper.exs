Mox.defmock(SkepticBot.EmbeddingMock, for: SkepticBot.Rag.Embedding)
Mox.defmock(SkepticBot.PredictionMock, for: SkepticBot.Rag.Generation)
Application.put_env(:skeptic_bot, :rag_embedding_module, SkepticBot.EmbeddingMock)
Application.put_env(:skeptic_bot, :rag_prediction_module, SkepticBot.PredictionMock)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SkepticBot.Repo, :manual)
