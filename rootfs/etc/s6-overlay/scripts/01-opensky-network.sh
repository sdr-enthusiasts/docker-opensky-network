#!/command/with-contenv bash
# shellcheck shell=bash

# Check to make sure the correct command line arguments have been set
EXITCODE=0
if [ -z "${LAT}" ]; then
    echo "ERROR: LAT environment variable not set"
    EXITCODE=1
fi
if [ -z "${LONG}" ]; then
    echo "ERROR: LONG environment variable not set"
    EXITCODE=1
fi
if [ -z "${BEASTHOST}" ]; then
    echo "ERROR: BEASTHOST environment variable not set"
    EXITCODE=1
fi
if [ -z "${ALT}" ]; then
    echo "ERROR: ALT environment variable not set"
    EXITCODE=1
fi
if [ -z "${OPENSKY_USERNAME}" ]; then
    echo "ERROR: OPENSKY_USERNAME environment variable not set"
    EXITCODE=1
fi
if [ $EXITCODE -ne 0 ]; then
    exit 1
fi

# Set up timezone
if [ -z "${TZ}" ]; then
    echo "WARNING: TZ environment variable not set"
else
    ln -snf "/usr/share/zoneinfo/$TZ" /etc/localtime && echo "$TZ" >/etc/timezone
fi

# Generate config based on environment variables
CONFIGFILE=/var/lib/openskyd/conf.d/10-opensky.conf
{
    echo "[GPS]"
    echo "Latitude=${LAT}"
    echo "Longitude=${LONG}"
    echo "Altitude=${ALT}"
    echo ""
    echo "[DEVICE]"
    echo "Type=${OPENSKY_DEVICE_TYPE}"
    echo ""
    echo "[IDENT]"
    echo "Username=${OPENSKY_USERNAME}"
    echo ""
    echo "[INPUT]"
    echo "Host=${BEASTHOST}"
    echo "Port=${BEASTPORT:=30005}"
} >${CONFIGFILE}

if [ -z "${OPENSKY_SERIAL}" ]; then
    echo ""
    echo "WARNING: OPENSKY_SERIAL environment variable was not set!"
    echo "Please make sure you note down the serial generated."
    echo "Pass the key as environment var OPENSKY_SERIAL on next launch!"
    echo ""
else
    CONFIGFILE=/var/lib/openskyd/conf.d/05-serial.conf
    {
        echo "[Device]"
        echo "serial = ${OPENSKY_SERIAL}"
    } >${CONFIGFILE}
fi
