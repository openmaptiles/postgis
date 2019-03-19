#!/bin/bash
set -o errexit
set -o pipefail
set -o nounset

for db in template_postgis "$POSTGRES_DB"; do
PGUSER="$POSTGRES_USER" psql --dbname="$db" <<-'EOSQL'
    CREATE EXTENSION IF NOT EXISTS hstore;
    CREATE EXTENSION IF NOT EXISTS unaccent;
    CREATE EXTENSION IF NOT EXISTS osml10n;
EOSQL
done
