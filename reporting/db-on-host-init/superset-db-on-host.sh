#!/bin/bash
set -e

# Superset DB and user configuration
DB_HOST="${POSTGRES_HOST:-172.17.0.1}"
DB_PORT="${POSTGRES_PORT:-5433}"
DB_ADMIN_USER="${POSTGRES_USER:-postgres}"
DB_ADMIN_PASS="${POSTGRES_PASSWORD:-postgres}"

SUPERSET_DB="${SUPERSET_POSTGRES_USER:-superset}"
SUPERSET_USER="${SUPERSET_POSTGRES_USER:-superset}"
SUPERSET_PASS="${SUPERSET_POSTGRES_PASSWORD:-superset_pass}"

export PGPASSWORD="$DB_ADMIN_PASS"

echo "🔍 Connecting to $DB_HOST:$DB_PORT as $DB_ADMIN_USER to create Superset DB/user..."

# Check if user exists
if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" -tAc "SELECT 1 FROM pg_roles WHERE rolname='$SUPERSET_USER'" | grep -q 1; then
  echo "✅ Superset user '$SUPERSET_USER' already exists, skipping creation."
else
  echo "👤 Creating user '$SUPERSET_USER'..."
  psql -v ON_ERROR_STOP=1 -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" <<-EOSQL
      CREATE USER $SUPERSET_USER WITH PASSWORD '$SUPERSET_PASS';
EOSQL
fi

# Check if DB exists
if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" -lqt | cut -d \| -f 1 | grep -qw "$SUPERSET_DB"; then
  echo "✅ Superset database '$SUPERSET_DB' already exists, skipping creation."
else
  echo "📦 Creating Superset database '$SUPERSET_DB'..."
  psql -v ON_ERROR_STOP=1 -h "$DB_HOST" -p "$DB_PORT" -U "$DB_ADMIN_USER" <<-EOSQL
      CREATE DATABASE $SUPERSET_DB;
      GRANT ALL PRIVILEGES ON DATABASE $SUPERSET_DB TO $SUPERSET_USER;
EOSQL
fi

echo "✅ Superset DB and user setup complete"
