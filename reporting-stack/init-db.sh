#!/bin/bash
# =============================================================================
# Manual CDC init for existing databases.
# For automated init, use the docker-compose.reporting-stack.yml overlay
# which runs wait-and-init.sh automatically.
#
# Usage:
#   docker exec -i openlmis-ref-distro-db-1 psql -U postgres -d open_lmis \
#     < reporting-stack/init-db.sql
# =============================================================================
set -euo pipefail

CONTAINER="${1:-openlmis-ref-distro-db-1}"
echo "Running CDC init on container: $CONTAINER"
docker exec -i "$CONTAINER" psql -U postgres -d open_lmis < "$(dirname "$0")/init-db.sql"
echo "Done."
