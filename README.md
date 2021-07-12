# dev-random

|              |                                                            |
| ------------ | ---------------------------------------------------------- |
| name         | Python Ingress Module Boilerplate                          |
| version      | v0.0.1                                                     |
| docker image | [weevenetwork/weeve-boilerplate](https://linktodockerhub/) |
| tags         | Python, Flask, Docker, Weeve                               |
| authors      | Sanyam Arya                                                |


# NOTES

## Listen to

docker network create mjnet
docker run --network=mjnet --rm -e PORT=4000 -e LOG_HTTP_BODY=true -e LOG_HTTP_HEADERS=true --name echo jmalloc/echo-server
docker run --network=mjnet --rm -e ENDPOINT=echo -e PORT=4000 dev-random

<!-- docker run --detach -P jmalloc/echo-server -->
<!-- docker run -i -t --rm --env-file=./config.env -p $(PORT):$(PORT) --name="$(APP_NAME)" $(APP_NAME) -->

## Building images
For testing, the image is built locally.

```
export DOCKER_ID_USER='weevenetwork'
export DOCKER_CONTAINER_NAME=$

docker build -t ${DOCKER_ID_USER}/${DOCKER_CONTAINER_NAME}:latest ./$DOCKER_IMAGE_PATH/$DOCKER_CONTAINER_FOLDER
# docker build -t weevenetwork/go-mqtt-gobot:latest ./images/go-mqtt-gobot
```



***
## Table of Content
- [dev-random](#dev-random)
- [NOTES](#notes)
  - [Listen to](#listen-to)
  - [Building images](#building-images)
  - [Table of Content](#table-of-content)
  - [Description](#description)
    - [Features](#features)
  - [Environment Variables](#environment-variables)
    - [Module Specific](#module-specific)
    - [Set by the weeve Agent on the edge-node](#set-by-the-weeve-agent-on-the-edge-node)
  - [Directory Structure](#directory-structure)
    - [File Tree](#file-tree)
  - [As a module developer](#as-a-module-developer)
    - [Configuration](#configuration)
    - [Business Logic](#business-logic)
  - [Dependencies](#dependencies)
  - [Output/Egress](#outputegress)

***



## Description

Simple container to forward a random string to an HTTP endpoint.

### Features
1. Demonstrates mounting a device from the host into the container

## Environment Variables

### Module Specific
The following module configurations can be provided in a data service designer section on weeve platform:

| Name         | Environment Variables | type   | Description                                  |
| ------------ | --------------------- | ------ | -------------------------------------------- |
| Output Label | OUTPUT_LABEL          | string | The output label as which data is dispatched |

***

### Set by the weeve Agent on the edge-node

| Environment Variables | type   | Description                            |
| --------------------- | ------ | -------------------------------------- |
| EGRESS_API_HOST       | string | HTTP ReST endpoint for the next module |
| MODULE_NAME           | string | Name of the module                     |

## Directory Structure

| name    | description                |
| ------- | -------------------------- |
| main.py | Entry-point for the module |
| app     | The application directory  |


### File Tree

```bash

├── Dockerfile
├── README.md
├── app
│   ├── __init__.py
│   ├── config
│   │   ├── __init__.py
│   │   ├── application.py # Application/module specific configurations
│   │   ├── log.py # log configuration
│   │   └── weeve.py # Weeve agent specific configurations
│   ├── module
│   │   ├── __init__.py
│   │   ├── main.py # [*] Main logic for the module
│   ├── utils
│   │   ├── __init__.py
│   │   ├── booleanenv.py
│   │   ├── env.py
│   │   └── floatenv.py
│   └── weeve # THe weeve logic
│       ├── __init__.py
│       ├── egress.py # Egress data to the next module
├── docker-compose.yml
├── main.py
├── makefile
├── package.json
└── requirements.txt

```

## As a module developer

A module developer needs to add all the configuration and business logic.
### Configuration

* All the environment variables and global constants can be declared in the config package in the `application.py` file.
* It uses the utils to get values from the environment and are recommended to the developer to use.
  * `env` - Returns the value for the `ENVIRONMENT_VARIABLE` or the `default value`
  * `boolenv` - Returns the boolean value for the `ENVIRONMENT_VARIABLE` or `false`
  * `floatenv` - Returns the float value for the `ENVIRONMENT_VARIABLE` or `0.0`


```python
    APPLICATION = {
        "OUTPUT_LABEL": env("OUTPUT_LABEL", "temperature"),
        "OUTPUT_UNIT": env("OUTPUT_UNIT", "Celsius"),
    }
 ```

### Business Logic

All the module logic can be written in the module package.
   * The files can me modified for the module
      1. `main.py`
         * The function `module_main` takes the output of the validation function as an argument.
         * All the business logic about modules are written here
         * Returns `[ data , error ]`
      2. `weeve.egress`
         * The function `send_data` takes the output of the main logic as an argument.
         * Responsible for sending the data to the next module
         * *It is not advisable to change it, but can be easily modified by altering the `send_data` function*


## Dependencies

* requests
* python-dotenv

## Output/Egress
Output of this module is JSON body:

```node
{
    "<OUTPUT_LABEL>": <Processed data>,
    "output_unit": <OUTPUT_UNIT>,
    "<MODULE_NAME>Time": timestamp
}
```

* Here `OUTPUT_LABEL` and `OUTPUT_UNIT` are specified at the module creation and `Processed data` is data processed by Module Main function.
