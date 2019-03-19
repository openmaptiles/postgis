# PostGIS + OSM-specific extensions Docker image
[![](https://images.microbadger.com/badges/image/openmaptiles/postgis.svg)](https://microbadger.com/images/openmaptiles/postgis "Get your own image badge on microbadger.com") [![Docker Automated buil](https://img.shields.io/docker/automated/openmaptiles/postgis.svg)]()

This images is based on PostgreSQL 11 and PostGIS 2.5 [Docker image](https://hub.docker.com/r/mdillon/postgis/) and includes [osml10n extension](https://github.com/giggls/mapnik-german-l10n.git) - OSM-specific label manipulation support.

## Usage

Run a PostgreSQL container and mount it to a persistent data directory outside.

In this example we start up the container and create a database `osm` with the owner `osm` and password `osm`
and mount our local directory `./data` as storage.

```bash
docker run \
    -v $(pwd)/data:/var/lib/postgresql/data \
    -e POSTGRES_DB="osm" \
    -e POSTGRES_USER="osm" \
    -e POSTGRES_PASSWORD="osm" \
    -d openmaptiles/postgis
```

## Build

```bash
docker build -t openmaptiles/postgis .
```
