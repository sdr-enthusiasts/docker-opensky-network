#!/command/with-contenv bash
#shellcheck shell=bash

# Globals
S6_SERVICE_ROOT="/run/service"
STR_HEALTHY="OK"
STR_UNHEALTHY="UNHEALTHY"

EXITCODE=0

function check_service_deathtally () {
    local service_name
    service_name=${1}

    # build service path
    local service_path
    service_path="${S6_SERVICE_ROOT%/}/${service_name}"

    # ensure service path exists
    if [[ -d "$service_path" ]]; then

        # get service death tally since last check
        local service_deathtally
        service_deathtally=$(s6-svdt "${service_path}" | wc -l)

        # clear death tally
        s6-svdt-clear "${service_path}"

        # print the first part of the text
        echo -n "\"${service_name}\" death tally since last check: ${service_deathtally}"

        # if healthy/unhealthy...
        if [[ "$service_deathtally" -gt 0 ]]; then
            echo ": $STR_UNHEALTHY"
            EXITCODE=1
        else
            echo ": $STR_HEALTHY"
        fi
    else

        # if service directory doesn't exist, throw an error
        echo "ERROR: service path \"$service_path\" does not exist!"
        EXITCODE=1
    fi
}

# MAIN

set -o pipefail

check_service_deathtally 'opensky-feeder'

# make sure we're feeding beast/beastreduce data to opensky
if netstat -anp | grep -P '^tcp.*\:10004.*ESTABLISHED.*openskyd.*$' > /dev/null; then
    echo "established connection to opensky network. $STR_HEALTHY"
else
    echo "no established connection to opensky network. $STR_UNHEALTHY"
    EXITCODE=1
fi

# Attempt to resolve BEASTHOST into an IP address
if BEASTIP=$(getent hosts "$BEASTHOST" 2> /dev/null | cut -d ' ' -f 1); then
  :
  #echo "got host via getent"
elif BEASTIP=$(s6-dnsip4 "$BEASTHOST" 2> /dev/null); then
  :
  #echo "got host via s6-dnsip4"
else
  #echo "no host found"
  BEASTIP="$BEASTHOST"
fi

# Make sure we're connected to a BEASTHOST
if netstat -anp | grep "$BEASTIP:$BEASTPORT" | grep ESTABLISHED > /dev/null; then
    echo "established BEAST connection to \"$BEASTIP:$BEASTPORT\". $STR_HEALTHY"
else
    echo "no established BEAST connection to \"$BEASTIP:$BEASTPORT\". $STR_UNHEALTHY"
    EXITCODE=1
fi

exit $EXITCODE
