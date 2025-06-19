Mox.defmock(SkepticBot.MockDownloader, for: SkepticBot.Downloader)
Application.put_env(:skeptic_bot, :downloader, SkepticBot.MockDownloader)

Mox.defmock(SkepticBot.Rag.MockEmbedder, for: SkepticBot.Rag.Embedder)
Application.put_env(:skeptic_bot, :embedder, SkepticBot.Rag.MockEmbedder)

Mox.defmock(SkepticBot.MockHttpClient, for: SkepticBot.HttpClient)
Application.put_env(:skeptic_bot, :http_client, SkepticBot.MockHttpClient)

Mox.defmock(SkepticBot.Storage.MockStorageProvider, for: SkepticBot.Storage.StorageProvider)
Application.put_env(:skeptic_bot, :storage_provider, SkepticBot.Storage.MockStorageProvider)

Mox.defmock(SkepticBot.MockTranscriber, for: SkepticBot.Transcriber)
Application.put_env(:skeptic_bot, :transcriber, SkepticBot.MockTranscriber)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SkepticBot.Repo, :manual)
