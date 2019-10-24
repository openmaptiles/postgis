ARG POSTGRES_MAJOR=12
ARG POSTGIS_MAJOR=3
ARG OSML10N_VER=2.5.7

FROM postgres:${POSTGRES_MAJOR} AS builder

ARG POSTGRES_MAJOR
ARG POSTGIS_MAJOR
ARG OSML10N_VER

USER root

# Compile mapnik
RUN apt-get update \
   && apt-get install -y postgresql-server-dev-${POSTGRES_MAJOR} devscripts equivs git

ADD https://github.com/giggls/mapnik-german-l10n/archive/v${OSML10N_VER}.tar.gz /tmp/mapnik-german-l10n.tar.gz

RUN cd /tmp \
   && tar xvf mapnik-german-l10n.tar.gz \
   && cd mapnik-german-l10n-${OSML10N_VER} \
   && cat debian/control \
   && DEBIAN_FRONTEND=noninteractive mk-build-deps -ir -t "apt-get -qq --no-install-recommends" debian/control \
   && PG_SUPPORTED_VERSIONS=${POSTGRES_MAJOR} make deb

# Build gdal with PG 12 support (https://github.com/OSGeo/gdal/commit/963618e77de4eee5e7321f5f5ca7abc2b7287fa2)
WORKDIR /tmp/build

RUN echo "deb-src http://deb.debian.org/debian buster main" >> /etc/apt/sources.list

RUN apt-get update && apt -y build-dep gdal-bin
RUN git clone --single-branch --branch release/2.4 https://github.com/OSGeo/gdal.git
RUN cd gdal && git checkout 963618e77de4eee5e7321f5f5ca7abc2b7287fa2
RUN cd gdal/gdal && ls && ./configure && make && make install DESTDIR=/tmp/gdal

RUN mkdir /tmp/deb && \
    mv /tmp/postgresql-${POSTGRES_MAJOR}-osml10n_${OSML10N_VER}_$(dpkg --print-architecture).deb \
       /tmp/deb

FROM postgres:${POSTGRES_MAJOR}

MAINTAINER "Lukas Martinelli <me@lukasmartinelli.ch>"

ARG POSTGRES_MAJOR
ARG POSTGIS_MAJOR
ARG OSML10N_VER=2.5.7

COPY --from=builder /tmp/deb /tmp/deb
COPY --from=builder /tmp/gdal/ /
RUN apt-get update \
   && apt-get install -y postgresql-${POSTGRES_MAJOR}-postgis-${POSTGIS_MAJOR} /tmp/deb/* \
   && rm -rf /var/lib/apt/lists/*

ENV PROJSO libproj.so.13

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
