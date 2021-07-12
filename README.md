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



