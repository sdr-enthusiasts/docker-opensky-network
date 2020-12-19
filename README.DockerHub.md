# mikenye/opensky-network

[![GitHub Workflow Status](https://img.shields.io/github/workflow/status/mikenye/docker-opensky-network/Deploy%20to%20Docker%20Hub)](https://github.com/mikenye/docker-opensky-network/actions?query=workflow%3A%22Deploy+to+Docker+Hub%22)
[![Docker Pulls](https://img.shields.io/docker/pulls/mikenye/opensky-network.svg)](https://hub.docker.com/r/mikenye/opensky-network)
[![Docker Image Size (tag)](https://img.shields.io/docker/image-size/mikenye/opensky-network/latest)](https://hub.docker.com/r/mikenye/opensky-network)
[![Discord](https://img.shields.io/discord/734090820684349521)](https://discord.gg/sTf9uYF)

Docker container running [OpenSky Network's](https://opensky-network.org/)'s `opensky-feeder`. Designed to work in tandem with [mikenye/readsb-protobuf](https://hub.docker.com/repository/docker/mikenye/readsb-protobuf). Builds and runs on `x86_64`, `arm64`, `arm32v7` and `386`.

`opensky-feeder` pulls ModeS/BEAST information from a host or container providing ModeS/BEAST data, and sends data to PlaneFinder.

For more information on what `opensky-feeder` is, see here: <https://opensky-network.org/community/projects/30-dump1090-feeder>.

## Documentation

Please [read this container's detailed and thorough documentation in the GitHub repository.](https://github.com/mikenye/docker-opensky-network/blob/master/README.md)