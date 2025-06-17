Mox.defmock(SkepticBot.Rag.MockEmbedder, for: SkepticBot.Rag.Embedder)
Mox.defmock(SkepticBot.Rag.MockGenerator, for: SkepticBot.Rag.Generator)
Application.put_env(:skeptic_bot, :embedder, SkepticBot.Rag.MockEmbedder)
Application.put_env(:skeptic_bot, :generator, SkepticBot.Rag.MockGenerator)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SkepticBot.Repo, :manual)
