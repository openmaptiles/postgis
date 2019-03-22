FROM postgres:11
MAINTAINER "Lukas Martinelli <me@lukasmartinelli.ch>"
ENV POSTGIS_VERSION=2.5.1 \
    GEOS_VERSION=3.7.1 \
    PROTOBUF_VERSION=3.6.1 \
    PROTOBUF_C_VERSION=1.3.1 \
    UTF8PROC_TAG=v2.2.0 \
    MAPNIK_GERMAN_L10N_TAG=v2.5.4

RUN apt-get -qq -y update \
 && apt-get -qq -y --no-install-recommends install \
        autoconf \
        automake \
        autotools-dev \
        build-essential \
        ca-certificates \
        bison \
        cmake \
        curl \
        dblatex \
        docbook-mathml \
        docbook-xsl \
        git \
        gdal-bin \
        libcunit1-dev \
        libkakasi2-dev \
        libtool \
        pandoc \
        unzip \
        xsltproc \
        # PostGIS build dependencies
            libgdal-dev \
            libjson-c-dev \
            libproj-dev \
            libxml2-dev \
            postgresql-server-dev-$PG_MAJOR \
## GEOS
 && cd /opt/ \
 && curl -o /opt/geos.tar.bz2 http://download.osgeo.org/geos/geos-$GEOS_VERSION.tar.bz2 \
 && mkdir /opt/geos \
 && tar xf /opt/geos.tar.bz2 -C /opt/geos --strip-components=1 \
 && cd /opt/geos/ \
 && ./configure \
 && make -j \
 && make install \
 && rm -rf /opt/geos* \
## Protobuf
 && cd /opt/ \
 && curl -L https://github.com/google/protobuf/archive/v$PROTOBUF_VERSION.tar.gz | tar xvz && cd protobuf-$PROTOBUF_VERSION \
 && ./autogen.sh \
 && ./configure \
 && make \
 && make install \
 && ldconfig \
 && rm -rf /opt/protobuf-$PROTOBUF_VERSION \
## Protobuf-c
 && cd /opt/ \
 && curl -L https://github.com/protobuf-c/protobuf-c/releases/download/v$PROTOBUF_C_VERSION/protobuf-c-$PROTOBUF_C_VERSION.tar.gz | tar xvz && cd protobuf-c-$PROTOBUF_C_VERSION \
 && ./configure \
 && make \
 && make install \
 && ldconfig \
 && rm -rf /opt/protobuf-c-$PROTOBUF_C_VERSION \
## Postgis
 && cd /opt/ \
 && curl -L https://download.osgeo.org/postgis/source/postgis-$POSTGIS_VERSION.tar.gz | tar xvz && cd postgis-$POSTGIS_VERSION \
 && ./autogen.sh \
 && ./configure CFLAGS="-O0 -Wall" \
 && make \
 && make install \
 && ldconfig \
 && rm -rf /opt/postgis-$POSTGIS_VERSION \
## UTF8Proc
 && cd /opt/ \
 && git clone https://github.com/JuliaLang/utf8proc.git \
 && cd utf8proc \
 && git checkout -q $UTF8PROC_TAG \
 && make \
 && make install \
 && ldconfig \
 && rm -rf /opt/utf8proc \
## Mapnik German
 && cd /opt/ \
 && git clone https://github.com/giggls/mapnik-german-l10n.git \
 && cd mapnik-german-l10n \
 && git checkout -q $MAPNIK_GERMAN_L10N_TAG \
 && make \
 && make install \
 && rm -rf /opt/mapnik-german-l10n \
## Cleanup
 && apt-get -qq -y --auto-remove purge \
        autoconf \
        automake \
        autotools-dev \
        build-essential \
        ca-certificates \
        bison \
        cmake \
        curl \
        dblatex \
        docbook-mathml \
        docbook-xsl \
        git \
        libcunit1-dev \
        libtool \
        make \
        g++ \
        gcc \
        pandoc \
        unzip \
        xsltproc \
        libpq-dev \
        postgresql-server-dev-$PG_MAJOR \
        libxml2-dev \
        libjson-c-dev \
        libgdal-dev \
&& rm -rf /usr/local/lib/*.a \
&& rm -rf /var/lib/apt/lists/*

COPY ./initdb-postgis.sh /docker-entrypoint-initdb.d/10_postgis.sh
