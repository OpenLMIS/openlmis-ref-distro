-- =============================================================================
-- Reporting Stack: Database initialization for Debezium CDC
-- =============================================================================
-- This script is idempotent — safe to run multiple times.
-- It configures the OpenLMIS database as a CDC source for the reporting stack.
--
-- What it does:
--   1. Creates a publication for tables the reporting stack will capture
--   2. Creates a heartbeat table to prevent WAL bloat during idle periods
--   3. Ensures the database user has replication privileges
-- =============================================================================

-- 1. Publication: list of tables whose changes Debezium will capture.
--    Add or remove tables here as needed.
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'dbz_publication') THEN
    CREATE PUBLICATION dbz_publication FOR TABLE
      referencedata.facilities,
      referencedata.programs,
      referencedata.geographic_zones,
      requisition.requisitions,
      requisition.requisition_line_items;
    RAISE NOTICE 'Created publication dbz_publication';
  ELSE
    RAISE NOTICE 'Publication dbz_publication already exists';
  END IF;
END $$;

-- 2. Heartbeat table: Debezium writes to this periodically to advance the
--    replication slot, preventing WAL accumulation during idle periods.
CREATE TABLE IF NOT EXISTS public.reporting_heartbeat (
  id  INT PRIMARY KEY DEFAULT 1,
  ts  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
INSERT INTO public.reporting_heartbeat (id, ts) VALUES (1, NOW())
  ON CONFLICT (id) DO NOTHING;

-- 3. Replication privilege for the postgres user.
ALTER ROLE postgres WITH REPLICATION;

-- 4. WAL retention safety limit is applied separately by wait-and-init.sh
--    because ALTER SYSTEM cannot run inside a transaction.
--    See docs/source-db-setup.md in the reporting-stack repo for details.
