#!/usr/bin/env bash
# Scrape recent YouTube videos (last 2 days), insert into prod, and enqueue download jobs.
# Use as a daily workaround while the server proxy is out of credit.
# Cron: 0 9 * * * /path/to/skeptic_bot/scripts/scrape_youtube_daily.sh >> /tmp/yt_scrape.log 2>&1

set -euo pipefail

DATE=$(date -u +%Y%m%d)
TWO_DAYS_AGO="${1:-$(date -u -v-2d +%Y%m%d)}"  # optional first arg overrides default (macOS date syntax)
OUTPUT="/tmp/skeptic_bot_yt_daily_${DATE}.tsv"
SQL_FILE="/tmp/skeptic_bot_yt_daily_${DATE}.sql"

> "$OUTPUT"

scrape_channel() {
  local channel_url="$1"
  local podcast_name="$2"

  echo "[$(date -u +%H:%M:%S)] Scraping $podcast_name ..."

  # yt-dlp outputs literal \t (two chars), not real tabs — split on r'\t'
  PYTHONUTF8=1 yt-dlp \
    --flat-playlist \
    --dateafter "$TWO_DAYS_AGO" \
    --print "%(id)s\t%(title)s\t%(duration)s\t%(thumbnail)s\t%(webpage_url)s" \
    --no-warnings \
    "$channel_url" \
  | python3 -c "
import sys
podcast = sys.argv[1]
for line in sys.stdin:
    parts = line.rstrip('\n').split(r'\t')
    if len(parts) < 5:
        continue
    vid_id, title, duration, thumbnail, url = parts[0], parts[1], parts[2], parts[3], parts[4]
    print('\t'.join([vid_id, podcast, title, duration, thumbnail, url]))
" "$podcast_name" >> "$OUTPUT"
}

scrape_channel "https://www.youtube.com/@RealCandaceO/streams" "Candace"
scrape_channel "https://www.youtube.com/@deepwaterscsc/videos" "Deep Waters"
scrape_channel "https://www.youtube.com/@NephilimDeathSquad/streams" "Nephilim Death Squad"

COUNT=$(wc -l < "$OUTPUT" | tr -d ' ')
echo "Found $COUNT new videos"

if [[ "$COUNT" -eq 0 ]]; then
  echo "Nothing new, skipping import"
  exit 0
fi

python3 - "$OUTPUT" "$SQL_FILE" <<'PYEOF'
import sys

input_file = sys.argv[1]
sql_file = sys.argv[2]

lines = open(input_file).readlines()

with open(sql_file, "w") as f:
    f.write("BEGIN;\n\n")

    for line in lines:
        parts = line.rstrip("\n").split("\t")
        if len(parts) < 6:
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
PYEOF

scp "$SQL_FILE" root@46.225.1.182:/tmp/
INSERTED=$(ssh root@46.225.1.182 "su - combobulate -s /bin/bash -c \
  \"psql postgresql://combobulate:postgres@localhost/skeptic_bot \
    -f /tmp/skeptic_bot_yt_daily_${DATE}.sql 2>&1 | grep -c 'INSERT 0 1' || true\"")
echo "[$(date -u +%H:%M:%S)] Inserted $INSERTED new episodes (+ download jobs enqueued)"
