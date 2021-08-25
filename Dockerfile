FROM debian:buster-20210816-slim

ENV BEASTPORT=30005 \
    OPENSKY_DEVICE_TYPE=default \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

COPY rootfs/ /

RUN set -x && \
    apt-get update -y && \
    apt-get install --no-install-recommends -y \
        apt-transport-https \
        binutils \
        ca-certificates \
        curl \
        file \
        gnupg \
        net-tools \
        xz-utils \
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
    # Deploy s6-overlay
    curl -s https://raw.githubusercontent.com/mikenye/deploy-s6-overlay/master/deploy-s6-overlay.sh | sh && \
    # Clean up
    apt-get remove -y \
        apt-transport-https \
        binutils \
        ca-certificates \
        curl \
        file \
        gnupg \
        xz-utils \
        && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/* && \
    grep 'opensky-feeder' /VERSIONS | cut -d ' ' -f2- | tr -d ' ' > /CONTAINER_VERSION

# Set s6 init as entrypoint
ENTRYPOINT [ "/init" ]

# Add healthcheck
HEALTHCHECK --start-period=3600s --interval=600s CMD /scripts/healthcheck.sh
