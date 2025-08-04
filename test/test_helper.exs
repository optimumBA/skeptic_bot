Mox.defmock(SkepticBot.Podcasts.MockDownloader, for: SkepticBot.Podcasts.Downloader)
Application.put_env(:skeptic_bot, :downloader, SkepticBot.Podcasts.MockDownloader)

Mox.defmock(SkepticBot.Rag.MockEmbedder, for: SkepticBot.Rag.Embedder)
Application.put_env(:skeptic_bot, :embedder, SkepticBot.Rag.MockEmbedder)

Mox.defmock(SkepticBot.Rag.MockGenerator, for: SkepticBot.Rag.Generator)
Application.put_env(:skeptic_bot, :generator, SkepticBot.Rag.MockGenerator)

Mox.defmock(SkepticBot.Podcasts.MockHttpClient, for: SkepticBot.Podcasts.HttpClient)
Application.put_env(:skeptic_bot, :http_client, SkepticBot.Podcasts.MockHttpClient)

Mox.defmock(SkepticBot.Storage.MockStorageProvider, for: SkepticBot.Storage.StorageProvider)
Application.put_env(:skeptic_bot, :storage_provider, SkepticBot.Storage.MockStorageProvider)

Mox.defmock(SkepticBot.Podcasts.MockTranscoder, for: SkepticBot.Podcasts.Transcoder)
Application.put_env(:skeptic_bot, :transcoder, SkepticBot.Podcasts.MockTranscoder)

Mox.defmock(SkepticBot.Podcasts.MockTranscriber, for: SkepticBot.Podcasts.Transcriber)
Application.put_env(:skeptic_bot, :transcriber, SkepticBot.Podcasts.MockTranscriber)

Mox.defmock(SkepticBot.LookIntoIt.MockDownloader, for: SkepticBot.LookIntoIt.Downloader)
Application.put_env(:skeptic_bot, :yt_dlp_downloader, SkepticBot.LookIntoIt.MockDownloader)

ExUnit.start()
Ecto.Adapters.SQL.Sandbox.mode(SkepticBot.Repo, :manual)
