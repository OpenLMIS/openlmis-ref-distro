#!/bin/bash
#
# Generate ERD diagrams for all OpenLMIS service schemas
# using SchemaSpy against a PostgreSQL database.
#
# Usage:
#   ./generate-erds.sh --host <DB_HOST> --port <DB_PORT> --db <DB_NAME> --user <DB_USER> --password <DB_PASSWORD>
#
# Example (AWS RDS):
#   ./generate-erds.sh --host my-openlmis.abcdef123.us-east-1.rds.amazonaws.com --port 5432 --db open_lmis --user postgres --password 'p@ssw0rd'
#
# Example (local docker):
#   ./generate-erds.sh --host localhost --port 5432 --db open_lmis --user postgres --password 'p@ssw0rd'
#
# Output: ./erd-output/<schema_name>/index.html per service
#

set -euo pipefail

# --- Defaults, provide actual values---
# --- DO NOT COMMIT REAL CREDENTIALS ---
DB_HOST="changeme"
DB_PORT="changeme"
DB_NAME="changeme"
DB_USER="changeme"
DB_PASSWORD="changeme"
OUTPUT_DIR="$(pwd)/../erd-output"
CLEAN=true

# OpenLMIS service schemas
SCHEMAS=(
    "auth"
    "referencedata"
    "requisition"
    "fulfillment"
    "stockmanagement"
    "notification"
    "cce"
    "report"
    "buq"
    "hapifhir"
    "dhis2integration"
)

# --- Parse arguments ---
while [[ $# -gt 0 ]]; do
    case $1 in
        --host)       DB_HOST="$2"; shift 2 ;;
        --port)       DB_PORT="$2"; shift 2 ;;
        --db)         DB_NAME="$2"; shift 2 ;;
        --user)       DB_USER="$2"; shift 2 ;;
        --password)   DB_PASSWORD="$2"; shift 2 ;;
        --output)     OUTPUT_DIR="$2"; shift 2 ;;
        --schemas)    IFS=',' read -ra SCHEMAS <<< "$2"; shift 2 ;;
        --clean)      CLEAN=true; shift ;;
        -h|--help)
            sed -n '2,16p' "$0"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [[ -z "$DB_PASSWORD" ]]; then
    echo "Error: --password is required"
    exit 1
fi

if [[ "$CLEAN" == true && -d "$OUTPUT_DIR" ]]; then
    echo "Cleaning previous output: $OUTPUT_DIR"
    rm -rf "$OUTPUT_DIR"
fi

mkdir -p "$OUTPUT_DIR"

echo "============================================"
echo " OpenLMIS ERD Generator (SchemaSpy)"
echo "============================================"
echo " Host:     $DB_HOST"
echo " Port:     $DB_PORT"
echo " Database: $DB_NAME"
echo " User:     $DB_USER"
echo " Output:   $OUTPUT_DIR"
echo " Schemas:  ${SCHEMAS[*]}"
echo "============================================"
echo ""

# Attempt each schema and skip if it fails
SUCCEEDED=()
FAILED=()

for SCHEMA in "${SCHEMAS[@]}"; do
    echo ""
    echo "--- Generating ERD for schema: $SCHEMA ---"

    mkdir -p "$OUTPUT_DIR/$SCHEMA"
    chmod 755 "$OUTPUT_DIR/$SCHEMA"

    if docker run --rm --network host \
        --user "$(id -u):$(id -g)" \
        -v "$OUTPUT_DIR/$SCHEMA:/output" \
        schemaspy/schemaspy:latest \
        -t pgsql11 \
        -host "$DB_HOST" \
        -port "$DB_PORT" \
        -db "$DB_NAME" \
        -s "$SCHEMA" \
        -u "$DB_USER" \
        -p "$DB_PASSWORD" \
        -vizjs 2>&1; then
        SUCCEEDED+=("$SCHEMA")
        echo "  -> OK: $OUTPUT_DIR/$SCHEMA/index.html"
    else
        FAILED+=("$SCHEMA")
        echo "  -> SKIPPED (schema may not exist in this database)"
        rm -rf "$OUTPUT_DIR/$SCHEMA"
    fi
done

echo ""
echo "============================================"
echo " RESULTS"
echo "============================================"
echo " Succeeded: ${SUCCEEDED[*]:-none}"
echo " Failed:    ${FAILED[*]:-none}"
echo ""

if [[ ${#SUCCEEDED[@]} -gt 0 ]]; then
    # Generate index page linking to all service ERDs
    INDEX_FILE="$OUTPUT_DIR/index.html"
    cat > "$INDEX_FILE" <<'HEADER'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>OpenLMIS - Database ERDs</title>
    <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif; max-width: 900px; margin: 40px auto; padding: 0 20px; color: #333; }
        h1 { border-bottom: 2px solid #205493; padding-bottom: 10px; }
        .schema-list { list-style: none; padding: 0; }
        .schema-list li { margin: 8px 0; }
        .schema-list a { display: inline-block; padding: 10px 20px; background: #205493; color: #fff; text-decoration: none; border-radius: 4px; min-width: 200px; }
        .schema-list a:hover { background: #0b3d91; }
        .meta { color: #666; font-size: 0.9em; margin-top: 30px; }
    </style>
</head>
<body>
    <h1>OpenLMIS - Database ERDs</h1>
    <p>Entity-Relationship Diagrams for all OpenLMIS service schemas, generated with <a href="https://schemaspy.org/">SchemaSpy</a>.</p>
    <ul class="schema-list">
HEADER

    for S in "${SUCCEEDED[@]}"; do
        echo "        <li><a href=\"$S/index.html\">$S</a></li>" >> "$INDEX_FILE"
    done

    {
        echo '    </ul>'
        echo "    <p class=\"meta\">Generated on $(date -u '+%Y-%m-%d %H:%M UTC') from database <strong>$DB_NAME</strong></p>"
        echo '</body>'
        echo '</html>'
    } >> "$INDEX_FILE"

    echo ""
    echo "Open the index in your browser:"
    echo "  file://$INDEX_FILE"
fi

echo ""
echo "Done."
