FROM ghcr.io/sdr-enthusiasts/docker-baseimage:base

ENV BEASTPORT=30005 \
    OPENSKY_DEVICE_TYPE=default \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY rootfs/ /

RUN set -x && \
    TEMP_PACKAGES=() && \
    KEPT_PACKAGES=() && \
    TEMP_PACKAGES+=(apt-transport-https) && \
    TEMP_PACKAGES+=(binutils) && \
    TEMP_PACKAGES+=(xz-utils) && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
        "${KEPT_PACKAGES[@]}" \
        "${TEMP_PACKAGES[@]}" \
        && \
    # Add opensky-network repo
    curl --output - https://opensky-network.org/files/firmware/opensky.gpg.pub | apt-key add - && \
    echo deb https://opensky-network.org/repos/debian opensky custom > /etc/apt/sources.list.d/opensky.list && \
    apt-get update -y && \
    # Install opensky-feeder
    mkdir -p /src/opensky-feeder && \
    pushd /src/opensky-feeder && \
    chown _apt /src/opensky-feeder && \
    apt-get download opensky-feeder && \
    ar vx ./*.deb && \
    tar xvf data.tar.xz -C / && \
    mkdir -p /var/lib/openskyd/conf.d && \
    popd && \
    # Document version
    OPENSKY_VERSION=$(apt-cache show opensky-feeder | grep Version | cut -d " " -f 2) && \
    echo "opensky-feeder ${OPENSKY_VERSION}" >> /VERSIONS && \
    # Clean up
    apt-get remove -y "${TEMP_PACKAGES[@]}" && \
    apt-get autoremove -y && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/* && \
    # Document versions
    grep 'opensky-feeder' /VERSIONS | cut -d ' ' -f2- | tr -d ' ' > /CONTAINER_VERSION

# Set s6 init as entrypoint
ENTRYPOINT [ "/init" ]

# Add healthcheck
HEALTHCHECK --start-period=3600s --interval=600s CMD /scripts/healthcheck.sh
