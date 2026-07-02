#!/bin/bash
# =============================================================================
# Wait for the OpenLMIS database and Flyway migrations to complete,
# then run the CDC initialization SQL.
# =============================================================================
set -euo pipefail

MAX_WAIT=300  # seconds
INTERVAL=5

echo "reporting-stack-init: waiting for database to be ready..."

# Step 1: Wait for PostgreSQL to accept connections
elapsed=0
until pg_isready -q 2>/dev/null; do
  if [ "$elapsed" -ge "$MAX_WAIT" ]; then
    echo "ERROR: database not ready after ${MAX_WAIT}s" >&2
    exit 1
  fi
  sleep "$INTERVAL"
  elapsed=$((elapsed + INTERVAL))
done
echo "reporting-stack-init: database is accepting connections (${elapsed}s)"

# Step 2: Wait for Flyway migrations to create the target tables.
# The OpenLMIS Java services run Flyway on startup, which creates the schemas
# and tables. We need to wait for at least one target table to exist.
echo "reporting-stack-init: waiting for OpenLMIS tables (Flyway migrations)..."
elapsed=0
until psql -tAc "SELECT 1 FROM pg_tables WHERE schemaname='referencedata' AND tablename='facilities'" 2>/dev/null | grep -q 1; do
  if [ "$elapsed" -ge "$MAX_WAIT" ]; then
    echo "ERROR: target tables not found after ${MAX_WAIT}s — are OpenLMIS services running?" >&2
    echo "reporting-stack-init: continuing without init (run manually later)" >&2
    exit 0
  fi
  sleep "$INTERVAL"
  elapsed=$((elapsed + INTERVAL))
done
echo "reporting-stack-init: target tables found (${elapsed}s)"

# Step 3: Run the idempotent CDC init SQL
echo "reporting-stack-init: applying CDC configuration..."
psql -f /init-db.sql

# Step 4: Set WAL retention safety limit (ALTER SYSTEM must run outside a transaction)
# Caps how much WAL a replication slot can retain. If the reporting stack goes down
# and WAL exceeds this limit, PostgreSQL invalidates the slot instead of filling
# the disk. Debezium re-snapshots on reconnect — the database stays operational.
# 2GB is a conservative dev default; production should size based on write volume.
CURRENT_WAL_LIMIT=$(psql -tAc "SHOW max_slot_wal_keep_size;" 2>/dev/null || echo "unknown")
if [ "$CURRENT_WAL_LIMIT" = "-1" ] || [ "$CURRENT_WAL_LIMIT" = "0" ]; then
  echo "reporting-stack-init: setting max_slot_wal_keep_size = 2GB (was: $CURRENT_WAL_LIMIT)"
  psql -c "ALTER SYSTEM SET max_slot_wal_keep_size = '2GB';"
  psql -c "SELECT pg_reload_conf();"
else
  echo "reporting-stack-init: max_slot_wal_keep_size already set to $CURRENT_WAL_LIMIT"
fi

echo "reporting-stack-init: done"
