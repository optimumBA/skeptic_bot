Mox.defmock(SkepticBot.RagMock, for: SkepticBot.Rag)
Mox.defmock(SkepticBot.Rag.EmbeddingMock, for: SkepticBot.Rag.Embedding)
Application.put_env(:skeptic_bot, :rag_module, SkepticBot.RagMock)
Application.put_env(:skeptic_bot, :rag_embedding_module, SkepticBot.Rag.EmbeddingMock)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SkepticBot.Repo, :manual)
