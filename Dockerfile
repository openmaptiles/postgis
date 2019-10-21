ARG POSTGRES_MAJOR=12
ARG POSTGIS_MAJOR=3
ARG OSML10N_VER=2.5.7

FROM postgres:${POSTGRES_MAJOR} AS l10n

ARG POSTGRES_MAJOR
ARG POSTGIS_MAJOR
ARG OSML10N_VER

USER root

RUN apt-get update \
   && apt-get install -y postgresql-server-dev-${POSTGRES_MAJOR} devscripts equivs

ADD https://github.com/giggls/mapnik-german-l10n/archive/v${OSML10N_VER}.tar.gz /tmp/mapnik-german-l10n.tar.gz

RUN cd /tmp \
   && tar xvf mapnik-german-l10n.tar.gz \
   && cd mapnik-german-l10n-${OSML10N_VER} \
   && cat debian/control \
   && DEBIAN_FRONTEND=noninteractive mk-build-deps -ir -t "apt-get -qq --no-install-recommends" debian/control \
   && PG_SUPPORTED_VERSIONS=${POSTGRES_MAJOR} make deb

FROM postgres:${POSTGRES_MAJOR}

MAINTAINER "Lukas Martinelli <me@lukasmartinelli.ch>"

ARG POSTGRES_MAJOR
ARG POSTGIS_MAJOR
ARG OSML10N_VER=2.5.7

COPY --from=l10n /tmp/postgresql-${POSTGRES_MAJOR}-osml10n_${OSML10N_VER}_amd64.deb /tmp

RUN apt-get update \
   && apt-get install -y postgresql-${POSTGRES_MAJOR}-postgis-${POSTGIS_MAJOR} /tmp/postgresql-${POSTGRES_MAJOR}-osml10n_${OSML10N_VER}_amd64.deb \
   && rm -rf /var/lib/apt/lists/*

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
