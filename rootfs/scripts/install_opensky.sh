#!/bin/bash
# shellcheck shell=bash

set -e

FILEBINARY=$(which file) || exit 69
FOUND=0
if [ -z "$FILEBINARY" ]; then

    # If not available, build with no optimisations.
    # This should never happen, as it's included in the Dockerfile.
    echo "ERROR: 'file' (libmagic) not available, cannot detect architecture!"
    exit 69

else

    mkdir -p /src/opensky-feeder
    pushd /src/opensky-feeder
    chown _apt /src/opensky-feeder

    FILEOUTPUT=$("${FILEBINARY}" -L "${FILEBINARY}")

    # 32-bit x86
    # Example output:
    # /usr/bin/file: ELF 32-bit LSB shared object, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-musl-i386.so.1, stripped
    # /usr/bin/file: ELF 32-bit LSB shared object, Intel 80386, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=d48e1d621e9b833b5d33ede3b4673535df181fe0, stripped

    # x86-64
    # Example output:
    # /usr/bin/file: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-musl-x86_64.so.1, stripped
    # /usr/bin/file: ELF 64-bit LSB shared object, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 3.2.0, BuildID[sha1]=6b0b86f64e36f977d088b3e7046f70a586dd60e7, stripped
    if echo "${FILEOUTPUT}" | grep "x86-64" > /dev/null; then
        echo "Found x86-64 architecture."
        wget -q https://opensky-network.org/files/firmware/opensky-feeder_latest_amd64.deb
        FOUND=1
    fi

    if echo "${FILEOUTPUT}" | grep "AMD64" > /dev/null; then
        echo "Found AMD64 architecture."
        wget -q https://opensky-network.org/files/firmware/opensky-feeder_latest_amd64.deb
        FOUND=1
    fi

    # armel
    # /usr/bin/file: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux.so.3, for GNU/Linux 3.2.0, BuildID[sha1]=f57b617d0d6cd9d483dcf847b03614809e5cd8a9, stripped
    if echo "${FILEOUTPUT}" | grep "ARM" > /dev/null; then

        # ARCH="arm"

        # Future TODO - detect and support armv6

        # armhf
        # Example outputs:
        # /usr/bin/file: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-musl-armhf.so.1, stripped  # /usr/bin/file: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-armhf.so.3, for GNU/Linux 3.2.0, BuildID[sha1]=921490a07eade98430e10735d69858e714113c56, stripped
        # /usr/bin/file: ELF 32-bit LSB shared object, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-armhf.so.3, for GNU/Linux 3.2.0, BuildID[sha1]=921490a07eade98430e10735d69858e714113c56, stripped
        if echo "${FILEOUTPUT}" | grep "armhf" > /dev/null; then

            # Note - currently this script assumes the user is using an rpiv2 if it detects this CPU type,
            # however this may not always be the case. We should find a way to determine if the CPU has
            # videocore, and set rpiv2 if it does, or armv7-generic if it does not. This is a future TODO.
            echo "Found armhf architecture."
            wget -q https://opensky-network.org/files/firmware/opensky-feeder_latest_armhf.deb
            FOUND=1
        fi

        # arm64
        # Example output:
        # /usr/bin/file: ELF 64-bit LSB shared object, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-musl-aarch64.so.1, stripped
        # /usr/bin/file: ELF 64-bit LSB shared object, ARM aarch64, version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-aarch64.so.1, for GNU/Linux 3.7.0, BuildID[sha1]=a8d6092fd49d8ec9e367ac9d451b3f55c7ae7a78, stripped
        if echo "${FILEOUTPUT}" | grep "aarch64" > /dev/null; then
            echo "Found aarch64 architecture."
            wget -q https://opensky-network.org/files/firmware/opensky-feeder_latest_arm64.deb
            FOUND=1
        fi

    fi

    # If we don't have an architecture at this point, there's been a problem and we can't continue
    if [ $FOUND -eq 0 ]; then
        echo "ERROR: Unable to determine architecture"
        exit 255
    fi
fi

dpkg-deb -f ./*.deb Version > /IMAGE_VERSION
ar vx ./*.deb
# There is an issue with bookworm and this deb package. If we unzip it over /
# it appears to mess up the filesystem. So we unzip it to /tmp/opensky and
# then copy the binary to /usr/bin
mkdir /tmp/opensky
tar xvf data.tar.xz -C /tmp/opensky
mkdir -p /var/lib/openskyd/conf.d
mkdir -p /etc/openskyd/conf.d
cp /tmp/opensky/usr/bin/openskyd-dump1090 /usr/bin/

popd
