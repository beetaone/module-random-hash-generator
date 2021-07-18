FROM alpine:edge

RUN apk --no-cache add curl jq
RUN apk add --no-cache bash
SHELL ["/bin/bash", "-c"]

# EXPOSE 1883 9001

COPY ./image/entrypoint.sh /entrypoint.sh
COPY ./image/main.sh /main.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

# ENTRYPOINT ["/bin/bash", "-c", "/entrypoint.sh"]
ENTRYPOINT ["/entrypoint.sh"]
# ENTRYPOINT ["/entrypoint.sh"]