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
    TEMP_PACKAGES+=(file) && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    "${KEPT_PACKAGES[@]}" \
    "${TEMP_PACKAGES[@]}" \
    && \
    /scripts/install_opensky.sh && \
    # Clean up
    apt-get remove -y "${TEMP_PACKAGES[@]}" && \
    apt-get autoremove -y && \
    rm -rf /src/* /tmp/* /var/lib/apt/lists/* /scripts/install_opensky.sh && \
    # Document versions
    echo "Installed version of opensky $(cat IMAGE_VERSION)"

# Set s6 init as entrypoint
ENTRYPOINT [ "/init" ]

# Add healthcheck
HEALTHCHECK --start-period=3600s --interval=600s CMD /scripts/healthcheck.sh
