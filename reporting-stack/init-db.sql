-- =============================================================================
-- Reporting Stack: Database initialization for Debezium CDC
-- =============================================================================
-- This script is idempotent — safe to run multiple times.
-- It configures the OpenLMIS database as a CDC source for the reporting stack.
--
-- What it does:
--   1. Creates a publication for tables the reporting stack will capture
--   2. Creates a heartbeat table to prevent WAL bloat during idle periods
--   3. Creates a signal table for Debezium incremental snapshots
--   4. Ensures the database user has replication privileges
-- =============================================================================

-- 1. Heartbeat table: Debezium writes to this periodically to advance the
--    replication slot, preventing WAL accumulation during idle periods.
CREATE TABLE IF NOT EXISTS public.reporting_heartbeat (
  id  INT PRIMARY KEY DEFAULT 1,
  ts  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
INSERT INTO public.reporting_heartbeat (id, ts) VALUES (1, NOW())
  ON CONFLICT (id) DO NOTHING;

-- 2. Signal table: Debezium reads rows inserted here to trigger ad-hoc actions
--    such as incremental snapshots (used by `make snapshot-tables` for selective
--    re-snapshot of newly added tables without resetting all offsets).
--    Schema follows the Debezium 3.x source signal channel contract.
CREATE TABLE IF NOT EXISTS public.debezium_signal (
  id   VARCHAR(42)   PRIMARY KEY,
  type VARCHAR(32)   NOT NULL,
  data VARCHAR(2048)
);

-- 3. Publication: list of tables whose changes Debezium will capture.
--    Add or remove data tables in the lists below as needed.
--    The signal table is included unconditionally — required by Debezium's
--    source signal channel.
--
--    Two-step approach for idempotency:
--    a) CREATE if it doesn't exist (first run)
--    b) SET TABLE always (handles tables dropped and recreated by Flyway
--       in demo/refresh-db mode — PostgreSQL silently removes recreated
--       tables from publications)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'dbz_publication') THEN
    CREATE PUBLICATION dbz_publication FOR TABLE
      public.debezium_signal,
      referencedata.facilities,
      referencedata.programs,
      referencedata.geographic_zones,
      referencedata.orderables,
      referencedata.processing_periods,
      referencedata.processing_schedules,
      referencedata.facility_types,
      referencedata.supported_programs,
      referencedata.requisition_group_members,
      referencedata.requisition_group_program_schedules,
      requisition.requisitions,
      requisition.requisition_line_items,
      requisition.status_changes,
      requisition.stock_adjustments,
      requisition.stock_adjustment_reasons;
    RAISE NOTICE 'Created publication dbz_publication';
  ELSE
    RAISE NOTICE 'Publication dbz_publication already exists — ensuring tables are included';
  END IF;
END $$;

-- Always re-set the table list. This is a no-op if the tables are already
-- correct, and fixes the publication if tables were dropped/recreated.
ALTER PUBLICATION dbz_publication SET TABLE
  public.debezium_signal,
  referencedata.facilities,
  referencedata.programs,
  referencedata.geographic_zones,
  referencedata.orderables,
  referencedata.processing_periods,
  referencedata.processing_schedules,
  referencedata.facility_types,
  referencedata.supported_programs,
  referencedata.requisition_group_members,
  referencedata.requisition_group_program_schedules,
  requisition.requisitions,
  requisition.requisition_line_items,
  requisition.status_changes,
  requisition.stock_adjustments,
  requisition.stock_adjustment_reasons;

-- 4. Replication privilege for the postgres user.
ALTER ROLE postgres WITH REPLICATION;

-- 5. WAL retention safety limit is applied separately by wait-and-init.sh
--    because ALTER SYSTEM cannot run inside a transaction.
--    See docs/source-db-setup.md in the reporting-stack repo for details.
