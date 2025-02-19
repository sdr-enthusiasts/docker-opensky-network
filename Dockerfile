FROM ghcr.io/sdr-enthusiasts/docker-baseimage:base

ENV BEASTPORT=30005 \
    OPENSKY_DEVICE_TYPE=default \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY rootfs/ /

# hadolint ignore=DL3008,SC2086,SC2039,SC2068
RUN set -x && \
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    TEMP_PACKAGES+=(apt-transport-https) && \
    TEMP_PACKAGES+=(binutils) && \
    TEMP_PACKAGES+=(xz-utils) && \
    TEMP_PACKAGES+=(gnupg) && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    "${KEPT_PACKAGES[@]}" \
    "${TEMP_PACKAGES[@]}" \
    && \
    # Add opensky-network repo
    wget -q  -O - https://opensky-network.org/files/firmware/opensky.gpg.pub | apt-key add - && \
    echo deb https://opensky-network.org/repos/debian opensky custom > /etc/apt/sources.list.d/opensky.list && \
    apt-get update -y && \
    # Install opensky-feeder
    mkdir -p /src/opensky-feeder && \
    pushd /src/opensky-feeder && \
    chown _apt /src/opensky-feeder && \
    apt-get download opensky-feeder && \
    ar vx ./*.deb && \
    # There is an issue with bookworm and this deb package. If we unzip it over /
    # it appears to mess up the filesystem. So we unzip it to /tmp/opensky and
    # then copy the binary to /usr/bin
    mkdir /tmp/opensky && \
    tar xvf data.tar.xz -C /tmp/opensky && \
    mkdir -p /var/lib/openskyd/conf.d && \
    mkdir -p /etc/openskyd/conf.d && \
    cp /tmp/opensky/usr/bin/openskyd-dump1090 /usr/bin/ && \
    popd && \
    # Document version
    OPENSKY_VERSION=$(apt-cache show opensky-feeder | grep Version | cut -d " " -f 2) && \
    echo "opensky-feeder ${OPENSKY_VERSION}" >> /VERSIONS && \
    # Clean up
    apt-get remove -y "${TEMP_PACKAGES[@]}" && \
    apt-get autoremove -y && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/* && \
    # Document versions
    grep 'opensky-feeder' /VERSIONS | cut -d ' ' -f2- | tr -d ' ' > /IMAGE_VERSION

# Set s6 init as entrypoint
ENTRYPOINT [ "/init" ]

# Add healthcheck
HEALTHCHECK --start-period=3600s --interval=600s CMD /scripts/healthcheck.sh
