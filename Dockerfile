FROM ghcr.io/sdr-enthusiasts/docker-baseimage:base

ENV BEASTPORT=30005 \
    OPENSKY_DEVICE_TYPE=default \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY rootfs/ /

# hadolint ignore=DL3008,SC2086,SC2039,SC2068
RUN set -x && \
    # Install opensky-feeder
    mkdir -p /src/opensky-feeder && \
    wget -nv -O opensky-feeder.deb \
    "https://opensky-network.org/files/firmware/opensky-feeder_latest_$(dpkg --print-architecture).deb" && \
    dpkg -x opensky-feeder.deb /src/opensky-feeder && \
    cp /src/opensky-feeder/usr/bin/openskyd-dump1090 /usr/bin/ && \
    mkdir -p /var/lib/openskyd/conf.d && \
    mkdir -p /etc/openskyd/conf.d && \
    # Document version
    OPENSKY_VERSION=$(zcat src/opensky-feeder/usr/share/doc/opensky-feeder/changelog.Debian.gz | grep -P -o -m1 '(?<=openskyd \().*(?=\))') && \
    echo "opensky-feeder ${OPENSKY_VERSION}" >> /VERSIONS && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/* && \
    # Document versions
    grep 'opensky-feeder' /VERSIONS | cut -d ' ' -f2- | tr -d ' ' > /IMAGE_VERSION

# Set s6 init as entrypoint
ENTRYPOINT [ "/init" ]

# Add healthcheck
HEALTHCHECK --start-period=3600s --interval=600s CMD /scripts/healthcheck.sh
