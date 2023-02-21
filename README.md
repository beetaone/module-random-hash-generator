# Random Hash Generator

|           |                                                                             |
| --------- | --------------------------------------------------------------------------- |
| Name      | Random Hash Generator                                                       |
| Version   | v2.0.0                                                                      |
| DockerHub | [weevenetwork/dev-random](https://hub.docker.com/r/weevenetwork/dev-random) |
| Authors   | Marcus Jones                                                                |

- [Random Hash Generator](#random-hash-generator)
  - [Description](#description)
- [Features](#features)
  - [Environment Variables](#environment-variables)
    - [Module Specific](#module-specific)
    - [Set by the weeve Agent on the edge-node](#set-by-the-weeve-agent-on-the-edge-node)
- [Technical implementation](#technical-implementation)
  - [Ingress module description](#ingress-module-description)
  - [Random data device](#random-data-device)
  - [Generate hash string](#generate-hash-string)
  - [Package into JSON payload](#package-into-json-payload)
  - [Send as HTTP post](#send-as-http-post)

## Description

This module and project demonstrates a docker container reading data from a device (/dev/random), processing it (hashing) and sending it to the next module.

# Features

-   Simple and lightweight for testing
-   Strict assertions in shell script for parameters and volumes

## Environment Variables

### Module Specific

| Environment Variables | type   | Description                   |
| --------------------- | ------ | ----------------------------- |
| HASH                  | string | Hash function                 |
| INTERVAL              | string | Sleep interval in seconds     |
| LABEL                 | string | JSON key for the output hash. |

### Set by the weeve Agent on the edge-node

| Environment Variables | type   | Description                                    |
| --------------------- | ------ | ---------------------------------------------- |
| MODULE_NAME           | string | Name of the module                             |
| MODULE_TYPE           | string | Type of the module (Input, Processing, Output) |
| EGRESS_URLS           | string | HTTP ReST endpoint for the next module         |

# Technical implementation

## Ingress module description

The simple ingress module mounts the linux random device to generate and forward a random hash string.

## Random data device

The /dev/urandom device node in linux generates unlimited random bytes of data. The data is generated from the entropy pool.

Bytes can be collected in various ways, just as from any file;

The `dd` utility can read and convert data from a file. The following command would read 3 bytes of data.

`random="$(dd if=/dev/urandom bs=3 count=1)"`

The `head` utility can read lines of a file. The following command would read 4096 bytes of data.

`random=$(head -n 4096 /dev/urandom)`

## Generate hash string

The `sha256sum` utility hashes input. The utility outputs a `-` characture which can be cut for a clean output.

`echo My data | sha256sum | cut -f 1 -d " "`

## Package into JSON payload

The `jq` utility can be used to package data into a JSON structure. The following command would place a variable `$randomstring` into the key value pair.

`JSON_STRING=$( jq -n -r --arg hs "$randomstring" '{"random hash": $hs}' )`

## Send as HTTP post

The `curl` utility is used to send HTTP data as a POST request. To avoid escaping newline and space characters, the payload (`-d`) is piped in.

`echo $JSON_STRING | curl -d @- -H "Content-Type: application/json" -X POST http://url:port`
