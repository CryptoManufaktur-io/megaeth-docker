# Overview

Docker Compose for megaeth

Meant to be used with [central-proxy-docker](https://github.com/CryptoManufaktur-io/central-proxy-docker) for traefik
and Prometheus remote write; use `:ext-network.yml` in `COMPOSE_FILE` inside `.env` in that case.

If you want the RPC ports exposed locally, use `rpc-shared.yml` in `COMPOSE_FILE` inside `.env`.

## Quick Start

The `./megaethd` script can be used as a quick-start:

`./megaethd install` brings in docker-ce, if you don't have Docker installed already.

`cp default.env .env`

`nano .env` and adjust variables as needed, particularly mention-important-vars-here

`./megaethd up`

## Software update

To update the software, run `./megaethd update` and then `./megaethd up`

## Customization

`custom.yml` is not tracked by git and can be used to override anything in the provided yml files. If you use it,
add it to `COMPOSE_FILE` in `.env`

## Version

megaeth Docker uses a semver scheme.

This is megaeth Docker v1.0.0

## Public RPC namespaces

The snapshot's `environment.sh` enables the `admin` and `debug` namespaces on the public HTTP/WebSocket RPC. This repo overrides the lists after sourcing it, so they are `eth,net,web3,trace,txpool` by default. Set `RPC_HTTP_API` / `RPC_WS_API` in your untracked `.env` to change them (a value replaces the whole list), then re-create the container with `docker compose up -d --force-recreate`; no tracked file needs editing.
