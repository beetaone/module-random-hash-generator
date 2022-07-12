FROM alpine:edge

RUN apk --no-cache add curl jq

RUN apk add --no-cache bash
SHELL ["/bin/bash", "-c"]

COPY ./docker/docker-entrypoint.sh ./src/main.sh /

ENTRYPOINT ["/docker-entrypoint.sh"]

EXPOSE 80
