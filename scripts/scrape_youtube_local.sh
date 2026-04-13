#!/usr/bin/env bash
# Scrape all YouTube channels locally (no proxy needed) and save video metadata.
# Output: /tmp/skeptic_bot_youtube_videos.tsv
# TSV format: video_id \t podcast_name \t title \t duration \t thumbnail \t url

set -euo pipefail

OUTPUT="/tmp/skeptic_bot_youtube_videos.tsv"
> "$OUTPUT"

scrape_channel() {
  local channel_url="$1"
  local podcast_name="$2"

  echo "Scraping $podcast_name from $channel_url ..."

  # yt-dlp outputs literal \t (two chars), not real tabs — split on r'\t'
  PYTHONUTF8=1 yt-dlp \
    --flat-playlist \
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

  echo "Done $podcast_name"
}

scrape_channel "https://www.youtube.com/@RealCandaceO/streams" "Candace"
scrape_channel "https://www.youtube.com/@deepwaterscsc/videos" "Deep Waters"
scrape_channel "https://www.youtube.com/@NephilimDeathSquad/streams" "Nephilim Death Squad"

TOTAL=$(wc -l < "$OUTPUT" | tr -d ' ')
echo ""
echo "Done! $TOTAL videos saved to $OUTPUT"
echo "Columns: video_id | podcast_name | title | duration | thumbnail | url"
