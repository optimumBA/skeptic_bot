#!/bin/bash
set -e

echo "=== PostgreSQL Database Restoration with Optimized Settings ==="
echo "Setting up connection to database using dump file $DUMP_FILE..."

# Create temp directory in current folder
mkdir -p ./restore_temp

# Phase 1: First restore schema only (fastest) - use transaction safety (schema must be atomic)
echo "Phase 1: Restoring database schema..."
pg_restore --dbname="$DATABASE_URL&options=-c%20maintenance_work_mem%3D1GB" \
  --no-owner --no-privileges --section=pre-data \
  --single-transaction "$DUMP_FILE"

# Phase 2: Restore data with proper memory settings - use parallelism for speed
echo "Phase 2: Restoring data (may take time)..."
pg_restore --dbname="$DATABASE_URL&options=-c%20work_mem%3D1GB" \
  --no-owner --no-privileges --section=data \
  --jobs=2 "$DUMP_FILE"

# Phase 3: Restore all regular post-data objects (indexes and constraints) except vector indexes
echo "Phase 3: Restoring regular indexes and constraints (skipping vector indexes)..."
pg_restore --list "$DUMP_FILE" | grep -v "embedding_vector" | grep -E "INDEX |CONSTRAINT" > ./restore_temp/post_data.txt
pg_restore --dbname="$DATABASE_URL&options=-c%20maintenance_work_mem%3D1GB" \
  --no-owner --no-privileges --use-list=./restore_temp/post_data.txt \
  --jobs=2 "$DUMP_FILE"

# Phase 4: Create vector indexes with maximum memory - 2GB memory for 1 job
echo "Phase 4: Creating vector indexes with increased memory settings..."
psql "$DATABASE_URL" -c "
SET maintenance_work_mem = '2GB';

-- Create vector indexes
CREATE INDEX IF NOT EXISTS podcast_episode_transcriptions_embedding_vector_l2_ops_index 
ON public.podcast_episode_transcriptions USING ivfflat (embedding) WITH (lists='100');

CREATE INDEX IF NOT EXISTS podcast_episodes_embedding_vector_l2_ops_index 
ON public.podcast_episodes USING ivfflat (embedding) WITH (lists='100');
"

# Phase 5: Run ANALYZE to update statistics for query planning - 2GB since this is single job
echo "Phase 5: Running ANALYZE to optimize query planning..."
psql "$DATABASE_URL" -c "
SET maintenance_work_mem = '2GB';
ANALYZE;
"

echo "===== Database restoration complete! ====="
echo "Database has been restored with all tables, data and indexes from $DUMP_FILE"
