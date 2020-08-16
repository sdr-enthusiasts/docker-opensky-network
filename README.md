# mikenye/opensky-network

Docker container running [OpenSky Network's](https://opensky-network.org/)'s `opensky-feeder`. Designed to work in tandem with [mikenye/readsb](https://hub.docker.com/repository/docker/mikenye/readsb) or [mikenye/piaware](https://hub.docker.com/repository/docker/mikenye/piaware). Builds and runs on `x86_64`, `arm64` and `arm32v7` (see below).

`opensky-feeder` pulls ModeS/BEAST information from a host or container providing ModeS/BEAST data, and sends data to PlaneFinder.

For more information on what `opensky-feeder` is, see here: <https://opensky-network.org/community/projects/30-dump1090-feeder>.

## Supported tags and respective Dockerfiles

* `latest` (`master` branch, `Dockerfile`)
* Version and architecture specific tags available
* `development` (`dev` branch, `Dockerfile`, not recommended for production)

## Multi Architecture Support

Currently, this image should pull and run on the following architectures:

* `amd64`: Linux x86-64
* `arm32v7`: ARMv7 32-bit (Odroid HC1/HC2/XU4, RPi 2/3)
* `arm64`: ARMv8 64-bit (RPi 4 64-bit OSes)

## Obtaining an OpenSky Network Feeder Serial Number

First-time users should obtain a feeder serial number.

Firstly, make sure you have registered for an account on the [OpenSky Network website](https://opensky-network.org/), and have your username on-hand.

In order to obtain a feeder serial number, we will start a temporary container running `opensky-feeder`, which will connect to OpenSky Network and be issued a serial number. The container will automatically be stopped and cleaned up after 60 seconds.

To do this, run the command:

```shell
timeout 60s docker run \
    --rm \
    -it \
    --link dump1090:beast \
    -e LAT=YOURLATITUDE \
    -e LONG=YOURLONGITUDE \
    -e ALT=YOURALTITUDE \
    -e BEASTHOST=YOURBEASTHOST \
    -e OPENSKY_USERNAME=YOUROPENSKYUSERNAME \
    mikenye/opensky-network
```

Be sure to change the following:

* Replace `YOURLATITUDE` with the latitude of your antenna (xx.xxxxx)
* Replace `YOURLONGITUDE` with the longitude of your antenna (xx.xxxxx)
* Replace `YOURALTITUDE` with the altitude above sea level of your antenna *in metres*
* Replace `YOURBEASTHOST` with the IP or hostname of your Beast provider (`readsb`/`dump1090`)
* Replace `YOUROPENSKYUSERNAME` with your OpenSky Network username

Your container needs to know how to access the container or host running dump1090. Set a `--link` entry to point to the Docker container with your Beast provider. This example assumes it is called "dump1090" and that BEASTHOST is set to "beast".

Once the container has started, you should see a message such as:

```text
[s6-init] making user provided files available at /var/run/s6/etc...exited 0.
[s6-init] ensuring user provided files have correct perms...exited 0.
[fix-attrs.d] applying ownership & permissions fixes...
[fix-attrs.d] done.
[cont-init.d] executing container initialization scripts...
[cont-init.d] 01-opensky-network: executing...

WARNING: OPENSKY_SERIAL environment variable was not set!
Please make sure you note down the serial generated.
Pass the key as environment var OPENSKY_SERIAL on next launch!

[cont-init.d] 01-opensky-network: exited 0.
[cont-init.d] done.
[services.d] starting services
[services.d] done.
[opensky-feeder] [INFO] [COMP] Initialize STAT
[opensky-feeder] [INFO] [COMP] Initialize POS
[opensky-feeder] [INFO] [COMP] Initialize DEVTYPE
[opensky-feeder] [INFO] [COMP] Initialize NET
[opensky-feeder] [INFO] [COMP] Initialize TB
[opensky-feeder] [INFO] [COMP] Initialize SERIAL
[opensky-feeder] [INFO] [COMP] Initialize BUF
[opensky-feeder] [INFO] [COMP] Initialize RELAY
[opensky-feeder] [INFO] [COMP] Initialize RC
[opensky-feeder] [INFO] [COMP] Initialize FILTER
[opensky-feeder] [INFO] [COMP] Initialize RECV
[opensky-feeder] [INFO] [COMP] Start STAT
[opensky-feeder] [INFO] [COMP] Start POS
[opensky-feeder] [INFO] [COMP] Start DEVTYPE
[opensky-feeder] [INFO] [COMP] Start NET
[opensky-feeder] [INFO] [COMP] Start TB
[opensky-feeder] [INFO] [COMP] Start SERIAL
[opensky-feeder] [INFO] [COMP] Start RELAY
[opensky-feeder] [INFO] [COMP] Start RC
[opensky-feeder] [INFO] [COMP] Start FILTER
[opensky-feeder] [INFO] [COMP] Start RECV
[opensky-feeder] [INFO] [INPUT] Trying to connect to '10.0.0.1': [10.0.0.1]:30005
[opensky-feeder] [INFO] [INPUT] connected to '10.0.0.1'
[opensky-feeder] [INFO] [NET] Trying to connect to 'collector.opensky-network.org': [194.209.200.6]:10004
[opensky-feeder] [INFO] [NET] connected to 'collector.opensky-network.org'
[opensky-feeder] [INFO] [LOGIN] Sending Device ID 5, Version 2.1.7
[opensky-feeder] [INFO] [SERIAL] Requesting new serial number
[opensky-feeder] [INFO] [SERIAL] Got a new serial number: -1408234269
[opensky-feeder] [INFO] [LOGIN] Sending Serial Number -1408234269
[opensky-feeder] [INFO] [GPS] Sending position -33.3333°, +111.1111°, +100.8m
[opensky-feeder] [INFO] [LOGIN] Sending Username 'johnnytightlips'
[cont-finish.d] executing container finish scripts...
[cont-finish.d] done.
[s6-finish] waiting for services.
[s6-finish] sending all processes the TERM signal.
[s6-finish] sending all processes the KILL signal and exiting.
```

As you can see from the output above, we've been allocated a serial number of `-1408234269`.

Failure to specify the `OPENSKY_SERIAL` environment variable will cause a new feeder serial to be created every time the container is started. Please do the right thing and set `OPENSKY_SERIAL`!

## Up-and-Running with `docker run`

```shell
docker run \
 -d \
 --rm \
 --name opensky \
 -e TZ="YOURTIMEZONE" \
 -e BEASTHOST=YOURBEASTHOST \
 -e LAT=YOURLATITUDE \
 -e LONG=YOURLONGITUDE \
 -e ALT=YOURALTITUDE \
 -e OPENSKY_USERNAME=YOUROPENSKYUSERNAME \
 -e OPENSKY_SERIAL=YOUROPENSKYSERIAL \
 mikenye/opensky-network
```

Be sure to change the following:

* Replace `YOURLATITUDE` with the latitude of your antenna (xx.xxxxx)
* Replace `YOURLONGITUDE` with the longitude of your antenna (xx.xxxxx)
* Replace `YOURALTITUDE` with the altitude above sea level of your antenna *in metres*
* Replace `YOURBEASTHOST` with the IP or hostname of your Beast provider (`readsb`/`dump1090`)
* Replace `YOUROPENSKYUSERNAME` with your OpenSky Network username
* Replace `YOUROPENSKYSERIAL` with your OpenSky feeder serial

For example:

```shell
docker run \
 -d \
 --rm \
 --name opensky \
 -e TZ="Australia/Perth" \
 -e BEASTHOST=10.0.0.1 \
 -e LAT=-33.33333 \
 -e LONG=111.11111 \
 -e ALT=100.8 \
 -e OPENSKY_USERNAME=johnnytightlips \
 -e OPENSKY_SERIAL=-1408234269 \
 mikenye/opensky-network
```

Please note, the altitude figure is given in metres and no units should be specified.

## Up-and-Running with Docker Compose

```yaml
version: '2.0'

services:
  opensky:
    image: mikenye/opensky-network:latest
    tty: true
    container_name: opensky
    restart: always
    environment:
      - TZ=Australia/Perth
      - BEASTHOST=readsb
      - LAT=-33.33333
      - LONG=111.11111
      - ALT=100.8
      - OPENSKY_USERNAME=johnnytightlips
      - OPENSKY_SERIAL=-1408234269
    networks:
      - adsbnet
```

## Up-and-Running with Docker Compose, including `mikenye/readsb`

```yaml
version: '2.0'

networks:
  adsbnet:

services:

  readsb:
    image: mikenye/readsb:latest
    tty: true
    container_name: readsb
    restart: always
    devices:
      - /dev/bus/usb/001/007:/dev/bus/usb/001/007
    networks:
      - adsbnet
    command:
      - --dcfilter
      - --device-type=rtlsdr
      - --fix
      - --json-location-accuracy=2
      - --lat=-33.33333
      - --lon=111.11111
      - --metric
      - --mlat
      - --modeac
      - --ppm=0
      - --net
      - --stats-every=3600
      - --quiet
      - --write-json=/var/run/readsb

  opensky:
    image: mikenye/opensky-network:latest
    tty: true
    container_name: opensky
    restart: always
    environment:
      - TZ=Australia/Perth
      - BEASTHOST=readsb
      - LAT=-33.33333
      - LONG=111.11111
      - ALT=100.8
      - OPENSKY_USERNAME=johnnytightlips
      - OPENSKY_SERIAL=-1408234269
    networks:
      - adsbnet
```

The `readsb` commands above are an example. For an explanation of the `mikenye/readsb` image's configuration, see that image's readme.

## Runtime Environment Variables

There are a series of available environment variables:

| Environment Variable | Purpose                         | Default |
| -------------------- | ------------------------------- | ------- |
| `BEASTHOST`          | Required. IP/Hostname of a Mode-S/BEAST provider (dump1090/readsb) | |
| `BEASTPORT`          | Optional. TCP port number of Mode-S/BEAST provider (dump1090/readsy) | 30005 |
| `OPENSKY_USERNAME`   | Required. OpenSky Network Username | |
| `OPENSKY_SERIAL`     | Optional. OpenSky Feeder Serial | Automatically generated |
| `LAT` | Required. Latitude of the antenna | |
| `LONG` | Required. Longitude of the antenna | |
| `ALT` | Required. Altitude in *metres* | |
| `TZ`                 | Optional. Your local timezone | GMT     |

## Ports

No ports need to be mapped into this container.

## Logging

* All processes are logged to the container's stdout, and can be viewed with `docker logs [-f] container`.

## Getting Help

You can [log an issue](https://github.com/mikenye/docker-opensky-network/issues) on the project's GitHub.

I also have a [Discord channel](https://discord.gg/sTf9uYF), feel free to [join](https://discord.gg/sTf9uYF) and converse.
