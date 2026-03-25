# Reporting Stack Integration

This directory contains the configuration to connect [openlmis-ref-distro](../) to the [reporting-stack](https://github.com/soldevelo/reporting-stack) platform for CDC-based analytics. It replaces the legacy reporting stack (`reporting/`) which used NiFi + Kafka + Superset.

## How it works

The `docker-compose.reporting-stack.yml` overlay:

1. **Creates a shared network** (`reporting-shared`) that the reporting-stack platform joins to reach the OpenLMIS database
2. **Attaches the DB** to this network with hostname `olmis-db`
3. **Runs an init container** (`reporting-stack-init`) that waits for Flyway migrations to complete, then configures the database for Debezium CDC (publication, heartbeat table, replication role)

Everything is automated — no manual SQL or network commands needed.

**Resource requirements:** The full OpenLMIS stack consumes ~28GB RAM. When running both stacks together, set `KAFKA_HEAP_OPTS: "-Xms256m -Xmx512m"` on kafka-connect in the reporting-stack to avoid OOM.

## Usage

### Start ref-distro with reporting-stack support

```bash
# Standard ref-distro setup (settings.env must exist)
docker compose -f docker-compose.yml -f docker-compose.reporting-stack.yml up -d --build --force-recreate
```

> **Note:** The OLMIS team recommends `--build --force-recreate` to ensure images are rebuilt and containers start from a clean state. For faster restarts during development when you haven't changed any Dockerfiles or config, you can omit these flags:
> ```bash
> docker compose -f docker-compose.yml -f docker-compose.reporting-stack.yml up -d
> ```

### Dev profile (recommended for reporting-stack development)

The full OLMIS stack + reporting stack can exceed available memory. Use the dev profile to disable non-essential OLMIS services and reduce Java heap sizes:

```bash
docker compose -f docker-compose.yml \
  -f docker-compose.reporting-stack.yml \
  -f docker-compose.reporting-dev.yml \
  up -d
```

This keeps the services needed for UI login and CDC testing (db, auth, referencedata, requisition, notification, report, fulfillment, stockmanagement, reference-ui) and disables the rest (cce, buq, hapifhir, diagnostics, dhis2-integration, ftp). Saves ~2 GB vs the full stack.

To start the disabled services for a specific session, use the `full` profile:

```bash
docker compose -f docker-compose.yml \
  -f docker-compose.reporting-stack.yml \
  -f docker-compose.reporting-dev.yml \
  --profile full up -d
```

The init container will:
- Wait for PostgreSQL to accept connections
- Wait for OpenLMIS Flyway migrations to create the target tables
- Run the idempotent CDC initialization SQL
- Exit (one-shot)

### Start the reporting-stack platform

In the reporting-stack repository:

```bash
cp .env.example .env
# Set: SOURCE_PG_HOST=olmis-db  SOURCE_PG_USER=postgres  SOURCE_PG_PASSWORD=p@ssw0rd
make up
make setup
```

`make setup` is idempotent — it registers the connector, initializes ClickHouse, and runs all verification steps. To verify individual layers manually:

```bash
make verify-services    # Kafka, Connect, Apicurio, Kafka UI, ClickHouse
make verify-cdc         # Debezium connector + CDC topics
make verify-ingestion   # ClickHouse raw landing has data
```

## Re-running the init

The init SQL is idempotent. To re-run it on an existing database:

```bash
bash reporting-stack/init-db.sh
```

Or directly:

```bash
docker exec -i openlmis-ref-distro-db-1 psql -U postgres -d open_lmis \
  < reporting-stack/init-db.sql
```

## Files

| File | Purpose |
|---|---|
| `init-db.sql` | Idempotent SQL: creates CDC publication, heartbeat table, replication role |
| `wait-and-init.sh` | Entrypoint for the init container: waits for DB + Flyway, then runs SQL |
| `init-db.sh` | Manual helper script for re-running init on existing databases |
| `../docker-compose.reporting-stack.yml` | Compose overlay: shared network + init container |

## What the init configures

- **Publication** `dbz_publication` for tables: `referencedata.facilities`, `referencedata.programs`, `referencedata.geographic_zones`, `requisition.requisitions`, `requisition.requisition_line_items`
- **Heartbeat table** `public.reporting_heartbeat` — prevents WAL bloat during idle CDC periods
- **Replication role** on the `postgres` user
- **WAL retention limit** `max_slot_wal_keep_size = 2GB` — prevents disk exhaustion if the reporting stack goes down (see below)

To capture additional tables, edit `init-db.sql` and re-run.

## WAL retention safety

If the reporting stack stops consuming (crash, maintenance), the Debezium replication slot prevents PostgreSQL from cleaning up WAL segments. Without a limit, WAL grows until the disk fills — causing a full database outage.

The init container sets `max_slot_wal_keep_size = 2GB` to cap WAL retention. Once exceeded, PostgreSQL invalidates the slot instead of filling the disk. Debezium will re-snapshot on reconnect.

**Verify after init:**

```bash
docker exec openlmis-ref-distro-db-1 psql -U postgres -d open_lmis \
  -c "SHOW max_slot_wal_keep_size;"
```

Expected output: `2GB`. If it shows `-1`, the limit was not applied — re-run the init container.

**Production sizing:** The `2GB` default is conservative for development. Production deployments should increase this based on write volume and acceptable downtime. See `docs/source-db-setup.md` in the reporting-stack repo for sizing guidance.

**Monitor slot lag:**

```bash
docker exec openlmis-ref-distro-db-1 psql -U postgres -d open_lmis -c "
  SELECT slot_name, active,
    pg_size_pretty(pg_wal_lsn_diff(pg_current_wal_lsn(), restart_lsn)) AS lag_size,
    wal_status
  FROM pg_replication_slots;
"
```
