#!/usr/bin/env bash
# Import scraped YouTube videos into prod DB and enqueue download jobs.
# Skips episodes that already exist (by external_id).
# Run AFTER scrape_youtube_local.sh has populated /tmp/skeptic_bot_youtube_videos.tsv
#
# TSV format: video_id | podcast_name | title | duration | thumbnail | url
#
# Usage: ./scripts/import_youtube_to_prod.sh [path/to/file.tsv]
#   Default input: /tmp/skeptic_bot_youtube_videos.tsv

set -euo pipefail

INPUT="${1:-/tmp/skeptic_bot_youtube_videos.tsv}"
SQL_FILE="/tmp/import_youtube_episodes.sql"

if [[ ! -f "$INPUT" ]]; then
  echo "ERROR: Input file not found: $INPUT"
  echo "Run scripts/scrape_youtube_local.sh first"
  exit 1
fi

echo "Building SQL from $INPUT ..."

python3 - "$INPUT" "$SQL_FILE" <<'PYEOF'
import sys
import json

input_file = sys.argv[1]
sql_file = sys.argv[2]

lines = open(input_file).readlines()
print(f"Processing {len(lines)} videos...")

with open(sql_file, "w") as f:
    f.write("BEGIN;\n\n")

    skipped = 0
    for line in lines:
        parts = line.rstrip("\n").split("\t")
        if len(parts) < 6:
            skipped += 1
            continue

        video_id     = parts[0]
        podcast_name = parts[1].replace("'", "''")
        title        = parts[2].replace("'", "''")
        duration_raw = parts[3]
        thumbnail    = parts[4].replace("'", "''") if parts[4] not in ("NA", "") else ""
        url          = parts[5].replace("'", "''")

        try:
            episode_length = int(float(duration_raw))
        except (ValueError, OverflowError):
            episode_length = 0

        # Build Oban job args (use original unescaped values for JSON)
        job_args = json.dumps({
            "id": "__EPISODE_ID__",  # placeholder, replaced below
            "podcast": parts[1],
            "video_url": parts[5],
        })

        # Insert episode and enqueue DownloadingWorker job in one go using a CTE
        f.write(
            f"WITH inserted AS (\n"
            f"  INSERT INTO episodes (podcast_id, external_id, title, episode_length, thumbnail, url, inserted_at, updated_at)\n"
            f"  SELECT p.id, '{video_id}', '{title}', {episode_length}, '{thumbnail}', '{url}', NOW(), NOW()\n"
            f"  FROM podcasts p\n"
            f"  WHERE p.name = '{podcast_name}'\n"
            f"    AND NOT EXISTS (SELECT 1 FROM episodes e WHERE e.external_id = '{video_id}')\n"
            f"  LIMIT 1\n"
            f"  RETURNING id\n"
            f")\n"
            f"INSERT INTO oban_jobs (queue, worker, args, max_attempts, state, inserted_at, scheduled_at)\n"
            f"SELECT 'downloading', 'SkepticBot.Podcasts.DownloadingWorker',\n"
            f"  jsonb_build_object('id', inserted.id::text, 'podcast', '{parts[1].replace(chr(39), chr(39)+chr(39))}', 'video_url', '{parts[5].replace(chr(39), chr(39)+chr(39))}'),\n"
            f"  5, 'available', NOW(), NOW()\n"
            f"FROM inserted;\n\n"
        )

    f.write("COMMIT;\n")
    if skipped:
        print(f"Skipped {skipped} malformed lines")

print(f"SQL written to {sql_file}")
PYEOF

echo "Transferring to server and running..."
scp "$SQL_FILE" root@46.225.1.182:/tmp/import_youtube_episodes.sql

echo "Running import..."
ssh root@46.225.1.182 "su - combobulate -s /bin/bash -c \
  \"psql postgresql://combobulate:postgres@localhost/skeptic_bot \
    -f /tmp/import_youtube_episodes.sql 2>&1 | grep -E '(INSERT|ERROR)' | sort | uniq -c\""

echo ""
echo "Row counts after import:"
ssh root@46.225.1.182 "su - combobulate -s /bin/bash -c \
  \"psql postgresql://combobulate:postgres@localhost/skeptic_bot -c \
    \\\"SELECT p.name, COUNT(*) FROM episodes e \
       JOIN podcasts p ON p.id = e.podcast_id \
       WHERE p.name IN ('Candace', 'Deep Waters', 'Nephilim Death Squad') \
       GROUP BY p.name ORDER BY p.name;\\\"\""
