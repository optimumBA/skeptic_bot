# Code quality policy

[Project README](../README.md) · [Exact check configuration](../.credo.exs)

The project uses released **KogenCredo 0.1.0**, **OptimumCredo 0.5.0** and
**Credo 1.7.19** as test/build dependencies. These libraries are independent:
KogenCredo detects recurring generated-code mistakes and test integrity problems;
OptimumCredo owns review conventions. No developer-machine path dependency is used.

## Run and verify

Start at the source root with pinned mise runtimes and the clean local test
environment described in the README. Run `make ci` for all existing checks,
including strict Credo and the added `mix optimum.heex_check` template scan
in a separate test-environment process. The released template task cannot safely
start Credo after a Credo run in the same VM; the separate process avoids that
lifecycle collision without changing or suppressing either check.
`mix credo --strict` checks inline HEEx; the separate task checks standalone
`.heex` files that stock Credo does not parse. Keep both commands failing on
findings. Dependency audits, coverage requirements, Dialyzer and rollback remain.

There are 34 explicitly configured KogenCredo checks and 74 OptimumCredo entries.
Some policies need explicit application settings; their exact values belong in
`.credo.exs`. Ash-only policies retain their library default off because this
application does not use Ash. No check module is assumed loaded merely because
Credo exits zero: verify the enabled modules after dependency upgrades, especially
when checks move between libraries.

## Project settings and reviewed boundaries

- Custom DataCase and ConnCase templates inherit async state in the test-state
  checks. PredictionHandler tests use an unnamed supervised process per test
  and run async. Downloader tests share FLAME/mock state; sitemap-worker tests
  change a shared file and its permissions. Only those two serial files have
  explicit reasons and exact `serial_allowed` entries.
- JSON/wire codecs are the Replicate client and webhook handlers, Tinfoil scraper,
  transcription adapter/worker, yt-dlp episode adapter and webhook verification
  plug. String keys are part of their external payload contracts. Other core
  modules remain checked, and job producers use atom keys where Oban encodes them.
- Existing downloader, transcoder, storage, Replicate, sitemap and web-plug error
  contracts return human-readable strings. ErrorReasonString excludes these
  named I/O/display edges rather than silently changing their caller contracts.
  Workers use matchable missing-record atoms. Req/storage rescue only expected
  file/transport exceptions; the yt-dlp System.cmd adapter retains its existing
  process-launch rescue at its explicit I/O boundary. Core code stays checked.
- ReplicateClient deliberately dispatches its declared behaviour callbacks, and
  the release helper iterates configured Ecto repositories. VariableModuleCall
  excludes those two files, not arbitrary variable names across the application.
- Phoenix's generated CoreComponents owns standard component markup; it is the
  sole SizeLimits exclusion. The standard telemetry metric list is split into
  groups. DomainSize enforces the existing podcasts/RAG/questions/web source
  groups. DomainReach is deliberately not enabled: a reviewed contract/port map
  is required before a syntactic cross-domain prohibition represents policy.
- Phoenix.ConnTest uses the public `@endpoint` caller attribute. The query-field
  inventory keeps intentional field ordering. Canonical URL generation may use
  Endpoint/Router from the core; other web-in-core dependencies remain checked.
- Total query/component operations document their tested empty/default boundary
  with a scoped describe tag. These tags do not skip tests or replace meaningful
  failure assertions. Every original assertion and coverage gate is retained.

No blanket file exclusion, per-line Credo suppression, skipped test or lowered
coverage threshold is used to clear findings. The NoCredoDisable detector is an
advisory gate inside Credo, not a tamper-proof trust boundary. KogenCredo's separate
integrity helpers can scan suppressions and compare a trusted external golden
configuration; this project does not claim an external golden-config authority.

## Implemented fixes and regression coverage

Stable query ordering includes an ID tie-breaker. Retrieval fetches at most six
episodes and their best transcriptions in two queries instead of one query per
episode; the regression checks query count, ordering and missing transcriptions.
Transcription writes are transactional: an invalid chunk rolls back earlier
chunks, returns the changeset and does not schedule a summary. That failure path
has a regression test. Scraper receives and streaming transactions have finite
30-minute deadlines. Webhook tests synchronize with their handler instead of
sleeping. Shared process names are injectable while default production names
remain unchanged. LiveView handles question-save errors using its existing error
message. Remaining edits follow the enabled naming, type, callback, assign and
migration conventions; the old experimental feature implementation is not imported.

## Upgrade, failure and completion

Read each package's current migration guide before upgrading and verify selected
checks exist. Run a focused scan, review findings against the actual API/behaviour,
fix confirmed defects and document justified settings at their owner. A detector
is a static hint, not proof of equivalent behaviour. Run focused regression tests
for behaviour changes, then the full gate and actual local warm WebSocket check
for affected LiveView/HTTP dependencies or lifecycle code. Keep logs and unfinished
findings outside the source tree; do not weaken a gate to hide a defect.
