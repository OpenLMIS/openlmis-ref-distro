#!/bin/bash
set -e

# Reporting DB configuration
DB_HOST="${POSTGRES_HOST:-172.17.0.1}"
DB_PORT="${POSTGRES_PORT:-5433}"
DB_NAME="${POSTGRES_DB:-open_lmis_reporting}"
DB_USER="${POSTGRES_USER:-postgres}"
DB_PASS="${POSTGRES_PASSWORD:-postgres}"

export PGPASSWORD="$DB_PASS"

echo "🔄 Connecting to PostgreSQL at $DB_HOST:$DB_PORT as user $DB_USER"

# Check if the reporting DB already exists
if psql -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME"; then
  echo "✅ Database '$DB_NAME' already exists, skipping creation."
else
  echo "📦 Creating database '$DB_NAME'..."
  psql -v ON_ERROR_STOP=1 -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" <<-EOSQL
      CREATE DATABASE $DB_NAME;
      GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;
EOSQL
fi

# Run schema setup
echo "📂 Applying schema from OlmisCreateTableStatements.sql..."
psql -v ON_ERROR_STOP=1 -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USER" -d "$DB_NAME" < /db-on-host-init/templates/OlmisCreateTableStatements.sql

echo "✅ Reporting DB initialized successfully"
