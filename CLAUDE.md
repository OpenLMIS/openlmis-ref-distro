# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OpenLMIS Reference Distribution — a Docker Compose orchestration layer that combines published OpenLMIS microservice Docker images into a running application. This repo contains no application source code; it wires together ~17 services (auth, requisition, referencedata, fulfillment, stockmanagement, notification, report, cce, buq, hapifhir, etc.) with infrastructure (PostgreSQL 14, Consul, Redis, Nginx, rsyslog, FTP).

## Common Commands

```bash
# First-time setup: copy and edit environment config
cp settings-sample.env settings.env

# Start all services (pulls images, runs detached)
docker-compose pull
docker-compose up -d

# Start with demo data loaded
./demo-data-start.sh

# Local dev start (auto-detects IP, configures settings.env)
./start-local.sh

# Rebuild from scratch
docker-compose up --build --remove-orphans --force-recreate

# Stop and destroy volumes
docker-compose down -v

# Reset database (drops all non-system schemas)
docker run -it --rm --env-file=.env --network=openlmisrefdistro_default \
  -v $(pwd)/cleanDb.sh:/cleanDb.sh openlmis/dev:3 /cleanDb.sh

# View centralized syslog
docker run -it --rm -v openlmis-ref-distro_syslog:/var/log openlmis/dev:3 tail /var/log/messages

# Build documentation (Sphinx)
cd docs/ && make html
```

### Reporting Stack Integration

```bash
# Dev profile (recommended) — disables non-essential OLMIS services, saves ~2 GB
docker compose -f docker-compose.yml \
  -f docker-compose.reporting-stack.yml \
  -f docker-compose.reporting-dev.yml \
  up -d --build --force-recreate

# Full profile — all OLMIS services (needs ~28 GB RAM)
docker compose -f docker-compose.yml -f docker-compose.reporting-stack.yml up -d --build --force-recreate

# Then in the reporting-stack repo (../openlmis-reporting):
cp .env.example .env  # set SOURCE_PG_HOST=olmis-db, SOURCE_PG_USER=postgres, SOURCE_PG_PASSWORD=p@ssw0rd
make up
make setup
```

## Architecture

### Configuration Flow

- **`.env`** — pins service image versions (`OL_REQUISITION_VERSION`, `OL_AUTH_VERSION`, etc.)
- **`settings.env`** (gitignored, copied from `settings-sample.env`) — all runtime config: DB credentials, URLs, mail, locale, timeouts, CORS, Spring profiles
- **`config/`** — builds a small Alpine container that serves `logback.xml` via a shared `service-config` volume mounted by every Java service

### Service Discovery & Networking

All services register with **Consul** and discover each other through it. Nginx routes external traffic using consul-template. Services are not accessed by `localhost` — container networking requires IP-based configuration (handled by `start-local.sh`).

### Health Checks

Java services expose `/actuator/health` on port 8080. Docker Compose health checks poll this endpoint (30s interval, 10 retries). Services declare `depends_on` with `condition: service_healthy` to sequence startup.

### Spring Profiles (`spring_profiles_active`)

| Profile | Effect |
|---------|--------|
| `demo-data` | Loads demo dataset on startup (default) |
| `performance-data` | Loads large dataset for load testing |
| `refresh-db` | Refreshes DB tables with extra checks; slower startup |
| `production` | **Required for prod** — prevents database wipes |
| *(none)* | Wipes database on every startup — avoid |

### Named Volumes

`olmis-db` (Postgres data), `service-config` (shared logback.xml), `syslog` / `nginx-log` / `consul-template-log` (centralized logging).

### Memory Allocation

Requisition and referencedata services get 1024 MB; all other Java services get 512 MB (set via `JAVA_OPTS` in docker-compose.yml).

### Reporting Stack (`reporting-stack/` + external repo)

CDC-based analytics platform: Debezium → Kafka → ClickHouse → dbt → Airflow → (Superset, planned). The platform lives in the sibling `openlmis-reporting` repo. This repo provides the integration overlay (`docker-compose.reporting-stack.yml`) that creates the `reporting-shared` network and initializes the DB for CDC.

The legacy NiFi-based reporting stack (`reporting/`) is deprecated and not used on this branch.

**Resource note:** Running both stacks together consumes ~28GB RAM. Set `KAFKA_HEAP_OPTS: "-Xms256m -Xmx512m"` on kafka-connect to avoid OOM.

### DHIS2 Integration (`dhis2/`)

Optional docker-compose for DHIS2 health information system integration.

## Key Conventions

- Never use `localhost` in configuration — always use the host machine's IP address (container networking requirement)
- Always set `spring_profiles_active=production` in production to prevent accidental database wipes
- Service versions are independently pinned in `.env`; update a single service by changing its version variable
- All Java services must mount the `service-config` volume to get `logback.xml`
- Compose variant files (`docker-compose.*.yml`) overlay the base for specific scenarios (demo data, ERD generation, extensions, OneNetwork integration)
