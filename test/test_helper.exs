Mox.defmock(SkepticBot.RagMock, for: SkepticBot.Rag)
Mox.defmock(SkepticBot.Rag.EmbeddingMock, for: SkepticBot.Rag.Embedding)
Mox.defmock(SkepticBot.PromptsMock, for: SkepticBot.Prompts)
Application.put_env(:skeptic_bot, :rag_module, SkepticBot.RagMock)
Application.put_env(:skeptic_bot, :rag_embedding_module, SkepticBot.Rag.EmbeddingMock)
Application.put_env(:skeptic_bot, :prompts_context_module, SkepticBot.PromptsMock)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SkepticBot.Repo, :manual)
