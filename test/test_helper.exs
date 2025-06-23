Mox.defmock(SkepticBot.Podcasts.MockDownloader, for: SkepticBot.Podcasts.Downloader)
Application.put_env(:skeptic_bot, :downloader, SkepticBot.Podcasts.MockDownloader)

Mox.defmock(SkepticBot.Rag.MockEmbedder, for: SkepticBot.Rag.Embedder)
Application.put_env(:skeptic_bot, :embedder, SkepticBot.Rag.MockEmbedder)

Mox.defmock(SkepticBot.MockHttpClient, for: SkepticBot.HttpClient)
Application.put_env(:skeptic_bot, :http_client, SkepticBot.MockHttpClient)

Mox.defmock(SkepticBot.Storage.MockStorageProvider, for: SkepticBot.Storage.StorageProvider)
Application.put_env(:skeptic_bot, :storage_provider, SkepticBot.Storage.MockStorageProvider)

Mox.defmock(SkepticBot.Podcasts.MockTranscoder, for: SkepticBot.Podcasts.Transcoder)
Application.put_env(:skeptic_bot, :transcoder, SkepticBot.Podcasts.MockTranscoder)

Mox.defmock(SkepticBot.Podcasts.MockTranscriber, for: SkepticBot.Podcasts.Transcriber)
Application.put_env(:skeptic_bot, :transcriber, SkepticBot.Podcasts.MockTranscriber)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SkepticBot.Repo, :manual)
